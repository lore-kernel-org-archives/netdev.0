From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] net: Keep interface binding when sending packets with
 ipi_ifindex = 0
Date: Mon, 27 Jul 2009 14:44:02 -0700
Message-ID: <20090727144402.513369f1.akpm@linux-foundation.org>
References: <6c039e090907231439t1def08a4n10978733bee55bec@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Chia-chi Yeh (=?ISO-8859-1?Q?=5F=5F=5F=5F=5F=5F=5F=5F=5F?=)
	<chiachi@android.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41888 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755207AbZG0VoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 17:44:05 -0400
In-Reply-To: <6c039e090907231439t1def08a4n10978733bee55bec@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(cc netdev)

On Thu, 23 Jul 2009 14:39:28 -0700
Chia-chi Yeh (_________) <chiachi@android.com> wrote:

> In IPv4, sending a packet with ipi_ifindex = 0 via an interface-bound
> socket will unbind the packet to that interface. This behavior is
> different from IPv6 which treats ipi6_ifindex = 0 as unspecified.
> Furthermore, IPv6 does not allow sending packets to other interface
> than the bound one, but I am not sure if it is necessary in IPv4. The
> following patch keeps the interface binding when ipi_ifindex = 0.
> 
> Thanks,
> Chia-chi
> 
> --- a/net/ipv4/ip_sockglue.c	2009-07-24 04:50:45.000000000 +0800
> +++ b/net/ipv4/ip_sockglue.c	2009-07-24 04:51:09.000000000 +0800
> @@ -213,7 +213,8 @@
>  			if (cmsg->cmsg_len != CMSG_LEN(sizeof(struct in_pktinfo)))
>  				return -EINVAL;
>  			info = (struct in_pktinfo *)CMSG_DATA(cmsg);
> -			ipc->oif = info->ipi_ifindex;
> +			if (info->ipi_ifindex)
> +				ipc->oif = info->ipi_ifindex;
>  			ipc->addr = info->ipi_spec_dst.s_addr;
>  			break;
>  		}

