From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Problem with frame time stamping
Date: Mon, 12 Nov 2007 17:47:59 +0100
Message-ID: <20071112174759.c2777ea2.dada1@cosmosbay.com>
References: <2cbbd8de0711120742h35f27441p5f096e5e99e1d7dc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org,
	netfilter-devel@vger.kernel.org, patrik.arlos@bth.se
To: "Antoine Zen-Ruffinen" <antoine.zen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:46132 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752349AbXKLQsG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2007 11:48:06 -0500
In-Reply-To: <2cbbd8de0711120742h35f27441p5f096e5e99e1d7dc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 12 Nov 2007 16:42:34 +0100
"Antoine Zen-Ruffinen" <antoine.zen@gmail.com> wrote:

> Dear all,
> 
> I'm writing a network analyzer software using Linux and I need a VERY
> precise frame time stamping. Therefor I am planing to add my own time
> stamping algorithm on a modified network driver. For test purpose I
> did so :
> 
> 	skb->tstamp.tv64 = 0x00010002;
> 	netif_rx(skb);
> 
> On the user side, I ask for the timestamp that way :
> 
> 	...
> 	sock = socket(AF_PACKET, SOCK_RAW, type);
> 	...
> 	//bind this socket with the interface using my modified driver.
> 	...
> 	recvByteCount = recv(sock, buffer, 1514, 0);
>     	ioctl(sock, SIOCGSTAMP, &timeStamp);
> 
> I was surprised to see that the var timeStamp was still holding a
> count of second since  year 1970.
> 
> Investigating a bit into the kernel code, I found that ioctl(sock,
> SIOCGSTAMP, ...) was giving just the current kernel time using
> ktime_get_real().
> 
> Are my investigation wrong ?
> Is that a bug in kernel code ?
> Is there an other way to access skb.tstamp from user side ?
> 
> Thank's to any one that can help me !

If your kernel is recent enough, you can already get nanosecond precision from skb tstamp, using SIOCGSTAMPNS ioctl or SO_TIMESTAMPNS / SCM_TIMESTAMPNS

(changes where done in March/April this year)

http://git2.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commit;h=b7aa0bf70c4afb9e38be25f5c0922498d0f8684c

http://git2.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commit;h=ae40eb1ef30ab4120bd3c8b7e3da99ee53d27a23

http://git2.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commit;h=92f37fd2ee805aa77925c1e64fd56088b46094fc


No need to modify a network driver :)


