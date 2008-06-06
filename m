From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen-pxSi+dnQzZMxHbG02/KK1g@public.gmane.org>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2213
Date: Fri, 6 Jun 2008 16:03:35 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806061509530.16829@wrl-59.cs.helsinki.fi>
References: <a4423d670806041450h17a2d3b1w40ea9ff8550a4b11@mail.gmail.com>
 <20080604.145244.07802877.davem@davemloft.net>
 <a4423d670806041529q6911f68fq68ee9ed8f8f50139@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexander Beregalov <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <a4423d670806041529q6911f68fq68ee9ed8f8f50139-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 5 Jun 2008, Alexander Beregalov wrote:

> 2008/6/5 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>:
> > From: "Alexander Beregalov" <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Date: Thu, 5 Jun 2008 01:50:49 +0400
> >
> >> I have got the following message:
> >
> > We need to know the exact kernel version you were running, what
> > kinds of things the system was doing at the time, etc.
> >
> 
> It is 2.6.26-rc3-00332-gcbff290.
> Host runs as a NFS server and rtorrent client.
> That is all network activity on it.
> I do not know what system was doing at this time, I have found this
> warning only after some time.

Thanks for reporting though I'm afraid that until there's somebody able
to reproduce it at least semi-often, this will remain unsolved. It's 
probably another reno all-segments already sacked_out situation where then 
one of them gets marked as lost in addition to that similar to the 
tcp_simple_retransmit that is already fixed in the kernel you're using. 
...In case you're worried, I'd say it has been there years and it won't 
corrupt anything anyway and the situation resolved itself on some later 
executed path (otherwise you'd see more than those two messages). They're 
visible only because I recently (in 2.6.23 or .24) started tracking these 
invariants by making them to complain and number of things have been 
already fixed because of that :-).

It seems that there is a small number of reports @ kerneloops.org for 
this same place but the count is noticably smaller (nearly by magnitude) 
than what it has been with the same type issues that were finally fixed 
couple of days ago, ie., after months of waiting. So there might not be
some near-term breakthrough coming up :-).

-- 
 i.
--
To unsubscribe from this list: send the line "unsubscribe kernel-testers" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
