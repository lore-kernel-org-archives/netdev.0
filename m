From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH v2] IPv6: fix bug when specifying the non-exist
 outgoing interface
Date: Tue, 03 Jun 2008 01:41:05 +0900 (JST)
Message-ID: <20080603.014105.73332390.yoshfuji@linux-ipv6.org>
References: <20080602.172009.84304151.yoshfuji@linux-ipv6.org>
	<4843B65C.1060702@cn.fujitsu.com>
	<48441C82.1070609@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: shanwei@cn.fujitsu.com, davem@davemloft.net,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:57967 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753423AbYFBQka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 12:40:30 -0400
In-Reply-To: <48441C82.1070609@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <48441C82.1070609@hp.com> (at Mon, 02 Jun 2008 12:14:58 -0400), Brian Haley <brian.haley@hp.com> says:

> Shan Wei wrote:
> >   When specifying the outgoing interface with sendmsg, if the ipi6_addr is 
> > the unspecified address and the ipi6_ifindex is the not-exist interface, 
> > it should be fail and the errno should be set ENODEV.
> >   Actually, it does well(sendmsg returns on success ), because the kernel 
> > don't check the interface。
> 
> This patch changes this code path to be different than most others that 
> completely ignore the device for the unspecified address - for example 
> inet6_bind() and rawv6_bind().  Those paths only care about the device 
> for a link-local address, so I don't think this patch is correct.

Semantics are different.  sin6_scope_id is valid ifindex only if
the scope is  link-local (Note: scope-id is scope-specific; 
for example, for "site-local" addresses, the values cannot be
directly mapped onto ifindex space).  On the other hand, ipi6_ifindex
is always effective even if the source address is global.

> In the current git tree, this :: address is going to turn-into ::1, so 
> the ifindex is irrelevant, the packet will be looped-back.  Older 
> kernels could transmit the packet on the wire using the default route. 
> Can you elaborate on the problem you were seeing?

Confused.  We are not talking about destination address but source
address, right?

--yoshfuji
