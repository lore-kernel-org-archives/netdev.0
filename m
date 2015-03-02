From: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Subject: Re: Weird TCP hang when doing loopback NFS (wireshark traces attached)
Date: Sun, 1 Mar 2015 19:52:28 -0500
Message-ID: <CAHQdGtSTJoKJZ8y72oLWTv30AZxVsRWAU0pTjZJy18jQ7Dhadw@mail.gmail.com>
References: <1425237291.24845.13.camel@primarydata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Network Devel Mailing List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux NFS Mailing List <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Bruce James Fields <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1425237291.24845.13.camel-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Bruce,

On Sun, Mar 1, 2015 at 2:14 PM, Trond Myklebust
<trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org> wrote:
> Hi,
>
> When doing testing of NFSv3 loopback mounts (client and server are on
> the same IP address), I'm seeing a very reproducible hang in which the
> client stops receiving data from the server. The TCP connection is still
> marked as established, and the server appears to continue to receive and
> send data, however the client does not.
>
> So far, I've reproduced on both v4.0-rc1, and the Fedora v3.18.7 kernel.
>
> The reproducer is simply to loopback mount using NFSv3, and then run the
> 'fsx' filesystem exerciser. I'm usually able to trigger the hang with
> "fsx -N 100000 foobar".
>
> I've attached a couple of wireshark trace of a few frames just before
> and during the hang in case it jogs any memories.

This bug appears to go away when I disable the splice()-based reads by
clearing the RQ_SPLICE_OK flag.

I noticed that it always involved a combination of a READ and a
truncating SETATTR call. Are you sure that it is safe to share
pagecache pages directly with sendpage() in this way? As far as I can
tell, there is no locking to prevent them from being modified while in
the TCP send queue.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
