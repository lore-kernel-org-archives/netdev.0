From: "Antoine Zen-Ruffinen" <antoine.zen@gmail.com>
Subject: Re: Problem with frame time stamping
Date: Tue, 13 Nov 2007 11:07:45 +0100
Message-ID: <2cbbd8de0711130207t82f2f46h9ee1b876a61bad6a@mail.gmail.com>
References: <2cbbd8de0711120742h35f27441p5f096e5e99e1d7dc@mail.gmail.com>
	 <20071112174759.c2777ea2.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org,
	netfilter-devel@vger.kernel.org, patrik.arlos@bth.se
To: "Eric Dumazet" <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:49711 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751533AbXKMKHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 05:07:47 -0500
Received: by nf-out-0910.google.com with SMTP id g13so1380580nfb
        for <netdev@vger.kernel.org>; Tue, 13 Nov 2007 02:07:45 -0800 (PST)
In-Reply-To: <20071112174759.c2777ea2.dada1@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

What does it bring me to have a nanosecond precision if it is not
related to the actual arrival of frame time ? As it seem I can feel
skb->tstamp with whatever I want, I always become something else using
ioctl(). (I'm using kernel 2.6.23).

2007/11/12, Eric Dumazet <dada1@cosmosbay.com>:
> On Mon, 12 Nov 2007 16:42:34 +0100
> "Antoine Zen-Ruffinen" <antoine.zen@gmail.com> wrote:
>
> > Dear all,
> >
> > I'm writing a network analyzer software using Linux and I need a VERY
> > precise frame time stamping. Therefor I am planing to add my own time
> > stamping algorithm on a modified network driver. For test purpose I
> > did so :
> >
> >       skb->tstamp.tv64 = 0x00010002;
> >       netif_rx(skb);
> >
> > On the user side, I ask for the timestamp that way :
> >
> >       ...
> >       sock = socket(AF_PACKET, SOCK_RAW, type);
> >       ...
> >       //bind this socket with the interface using my modified driver.
> >       ...
> >       recvByteCount = recv(sock, buffer, 1514, 0);
> >       ioctl(sock, SIOCGSTAMP, &timeStamp);
> >
> > I was surprised to see that the var timeStamp was still holding a
> > count of second since  year 1970.
> >
> > Investigating a bit into the kernel code, I found that ioctl(sock,
> > SIOCGSTAMP, ...) was giving just the current kernel time using
> > ktime_get_real().
> >
> > Are my investigation wrong ?
> > Is that a bug in kernel code ?
> > Is there an other way to access skb.tstamp from user side ?
> >
> > Thank's to any one that can help me !
>
> If your kernel is recent enough, you can already get nanosecond precision from skb tstamp, using SIOCGSTAMPNS ioctl or SO_TIMESTAMPNS / SCM_TIMESTAMPNS
>
> (changes where done in March/April this year)
>
> http://git2.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commit;h=b7aa0bf70c4afb9e38be25f5c0922498d0f8684c
>
> http://git2.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commit;h=ae40eb1ef30ab4120bd3c8b7e3da99ee53d27a23
>
> http://git2.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commit;h=92f37fd2ee805aa77925c1e64fd56088b46094fc
>
>
> No need to modify a network driver :)
>
>
>
