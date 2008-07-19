From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [RFC 2/2] TCP: Add TCP-AO support
Date: Sat, 19 Jul 2008 10:06:48 +0900 (JST)
Message-ID: <20080719.100648.63386563.yoshfuji@linux-ipv6.org>
References: <396556a20805301217k293e5718h6bbf02bfe069032@europa>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: agl@imperialviolet.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:32793 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592AbYGSBGu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 21:06:50 -0400
In-Reply-To: <396556a20805301217k293e5718h6bbf02bfe069032@europa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

>   * Only two keys supported (against a spec max of 256)

Do we have to manage all key at the same time?
I don't think so.

If yes...

In article <396556a20805301217k293e5718h6bbf02bfe069032@europa> (at Fri, 18 Jul 2008 17:22:10 -0700), "Adam Langley" <agl@imperialviolet.org> says:

> /* tcpa_flags */
> #define TCP_AUTH_ALLOW_KEY0		(1 << 0)
> #define TCP_AUTH_ALLOW_KEY1		(1 << 1)
> #define TCP_AUTH_TX_KEY1		(1 << 2)
> #define TCP_AUTH_RFC2385		(1 << 3)
> #define TCP_AUTH_OPTIONS_EXCLUDE	(1 << 4)
> #define TCP_AUTH_PSEUDOHEADER_EXCLUDE	(1 << 5)
> #define TCP_AUTH_PORT_NUMS_EXCLUDE	(1 << 6)
> #define TCP_AUTH_LATCH			(1 << 7)
> 
> struct tcp_auth {
> 	struct __kernel_sockaddr_storage tcpa_addr;	/* address associated */
> 	__u8	tcpa_key0[TCP_AUTH_MAXKEYLEN];		/* key0 (binary) */
> 	__u8	tcpa_key1[TCP_AUTH_MAXKEYLEN];		/* key1 (binary) */
> 	__u8	tcpa_key0len;				/* key0 length */
> 	__u8	tcpa_key1len;				/* key1 length */
> 	__u8	tcpa_macfunc;				/* MAC function */
> 	__u8	tcpa_flags;
> };

I think flags and number of keys should be extendable.
How about this?

struct tcp_auth {
      struct __kernel_sockaddr_storage tcpa_addr;
      __u32   tcpa_flags;
      __u8    tcpa_macfunc;
      __u8    tcpa_reserved;
      __u16   tcpa_txkey;
      __u8    tcpa_keylen[256];
      __u8    tcpa_key[TCP_AUTH_MAXKEYLEN];
      /* other keys follow */
};

--yoshfuji
