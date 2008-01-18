From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv4: Enable use of 240/4 address space
Date: Fri, 18 Jan 2008 11:13:19 +0900 (JST)
Message-ID: <20080118.111319.30002290.yoshfuji@linux-ipv6.org>
References: <Pine.LNX.4.64.0801180023450.18447@fbirervta.pbzchgretzou.qr>
	<20080118.102635.01689255.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.64.0801180242270.14025@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ak@suse.de, vaf@cisco.com,
	yoshfuji@linux-ipv6.org
To: jengelh@computergmbh.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:35500 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752960AbYARCNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 21:13:08 -0500
In-Reply-To: <Pine.LNX.4.64.0801180242270.14025@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <Pine.LNX.4.64.0801180242270.14025@fbirervta.pbzchgretzou.qr> (at Fri, 18 Jan 2008 02:52:08 +0100 (CET)), Jan Engelhardt <jengelh@computergmbh.de> says:

> 
> On Jan 18 2008 10:26, YOSHIFUJI Hideaki / 吉藤英明 wrote:
> >> -#define	IN_EXPERIMENTAL(a)	((((long int) (a)) & 0xf0000000) == 0xf0000000)
> >> -#define	IN_BADCLASS(a)		IN_EXPERIMENTAL((a))
> >
> >No, please keep these macros.
> >
> >> @@ -264,7 +261,7 @@ static inline bool ipv4_is_local_multicast(__be32 addr)
> >>  
> >>  static inline bool ipv4_is_badclass(__be32 addr)
> >>  {
> >> -	return (addr & htonl(0xf0000000)) == htonl(0xf0000000);
> >> +	return addr == 0xFFFFFFFF;
> >>  }
> >>  
> >
> >To (un)align the IN_BADCLASS macro and ipv6_is_badclass() definition,
> 
> Unalign? IPv6? "Limited" broadcast?

Sorry, ipv4_is_badclass().
Assuming IN_BADCLASS() is still there, we should not reuse the name
of "ipv6_is_badclass" because the their meanings are different.

> -static inline bool ipv4_is_badclass(__be32 addr)
> +static inline bool ipv4_is_broadcast(__be32 addr)
>  {

I'm just afraid that people might think ipv4_is_broadcast
is for testing subnet broadcast address.

255.255.255.255 is "limited broadcast address"
(vs subnet broadcast address, which can be forwarded by routers).

--yoshfuji
