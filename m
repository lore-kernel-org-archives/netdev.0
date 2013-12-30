From: Dan Williams <dan.j.williams@intel.com>
Subject: Re: net_dma: mark broken
Date: Mon, 30 Dec 2013 12:15:27 -0800
Message-ID: <CAPcyv4gQWWv-bq57=6BNVNnRCEdiy5dEE09Q2snO7nC76Xmvbw@mail.gmail.com>
References: <20131220211228.BC817660C74@gitolite.kernel.org>
	<20131223162113.GA20363@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f52.google.com ([209.85.212.52]:63752 "EHLO
	mail-vb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932172Ab3L3UP3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Dec 2013 15:15:29 -0500
Received: by mail-vb0-f52.google.com with SMTP id p5so6091435vbn.11
        for <netdev@vger.kernel.org>; Mon, 30 Dec 2013 12:15:28 -0800 (PST)
In-Reply-To: <20131223162113.GA20363@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 23, 2013 at 8:21 AM, Dave Jones <davej@redhat.com> wrote:
> On Fri, Dec 20, 2013 at 09:12:28PM +0000, Linux Kernel wrote:
>  > Gitweb:     http://git.kernel.org/linus/;a=commit;h=77873803363c9e831fc1d1e6895c084279090c22
>  > Commit:     77873803363c9e831fc1d1e6895c084279090c22
>  > Parent:     0baf8f6a2ac86c2c40ed0cacab8ea3d17371a1bb
>  > Author:     Dan Williams <dan.j.williams@intel.com>
>  > AuthorDate: Tue Dec 17 10:09:32 2013 -0800
>  > Committer:  Dan Williams <dan.j.williams@intel.com>
>  > CommitDate: Wed Dec 18 12:53:43 2013 -0800
>  >
>  >     net_dma: mark broken
>  >
>  >     net_dma can cause data to be copied to a stale mapping if a
>  >     copy-on-write fault occurs during dma.  The application sees missing
>  >     data.
>
>
> Since this commit, coverity picked up a possible logic contradiction in tcp_rcv_established
> Now that the only thing setting copied_early = 1 is inside an ifdef that won't be set,
> it notes that this code is unreachable..
>
> 5271                        if (!copied_early || tp->rcv_nxt != tp->rcv_wup)
> 5272                                __tcp_ack_snd_check(sk, 0);
>
> I don't understand all the subtleties of that huge function, so another
> set of eyes would be appreciated.  If it's a non-issue, I'll flag it as such
> for coverity so it doesn't get picked up again.

Unreachable?  Or is that the same report for something like "if()
statement has no effect"?  In any event that fix came from
"53240c208776 tcp: Fix possible double-ack w/ user dma" and can be
reverted to just call __tcp_ack_snd_check unconditionally.  I'll fold
it into the net_dma removal patch.

--
Dan
