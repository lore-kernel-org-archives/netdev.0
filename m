From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: RFC2292(bis) checksum support
Date: Mon, 20 May 2002 12:04:06 +0900
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020520120406A.yoshfuji@linux-ipv6.org>
References: <20020517015714M.yoshfuji@linux-ipv6.org>
	<200205192146.BAA00826@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200205192146.BAA00826@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

In article <200205192146.BAA00826@sex.inr.ac.ru> (at Mon, 20 May 2002 01:46:48 +0400 (MSD)), kuznet@ms2.inr.ac.ru says:

> This is supposed to be fixed in recent 2.4.19 and 2.5.

thanks!!!


> > (1) RFC2292bis denies usage of this interface for ICMPv6 socket,
> 
> OK. Yes, we can set default value for such sockets to 2, but I do not see
> any good reasons to limit functionality of the API just to follow evident
> mistake in the rfc. So, I would apply the last three chunks of the patch
> except for these lines:
> 
> +                       if (sk->num == IPPROTO_ICMPV6 && val != 2)
> +                               return(-EINVAL);

Would you tell us what the "evident mistake in the rfc" is, please?

Checksum for ICMPv6 is mandatory like ones for TCP and UDP (for IPv6) are.
We should not (be able to) disable checksum for TCP, UDP AND ICMPv6,
should we?


> One question only: what did you mean in the following chunk?
> Apparently, you forgot to delete marked line.
> 
>  			csum = (__u16 *) (buff + opt->offset);
>  			*csum = hdr->cksum;
> 			^^^^^^^^^^^^^^^^^^^
:
> Do I guess correctly that you wanted to compensate for occasionally
> ununitialized checksum bits in data supplied by user?

yes.  I just forgot to delete that original line while making this patch;
sorry.

--yoshfuji
