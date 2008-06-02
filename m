From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH v2] IPv6: fix bug when specifying the non-exist
 outgoing interface
Date: Tue, 03 Jun 2008 01:46:04 +0900 (JST)
Message-ID: <20080603.014604.26891059.yoshfuji@linux-ipv6.org>
References: <4843B65C.1060702@cn.fujitsu.com>
	<48441C82.1070609@hp.com>
	<20080603.014105.73332390.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: shanwei@cn.fujitsu.com, davem@davemloft.net,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:57974 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753252AbYFBQp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 12:45:29 -0400
In-Reply-To: <20080603.014105.73332390.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080603.014105.73332390.yoshfuji@linux-ipv6.org> (at Tue, 03 Jun 2008 01:41:05 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> In article <48441C82.1070609@hp.com> (at Mon, 02 Jun 2008 12:14:58 -0400), Brian Haley <brian.haley@hp.com> says:
> 
> > Shan Wei wrote:
> > >   When specifying the outgoing interface with sendmsg, if the ipi6_addr is 
> > > the unspecified address and the ipi6_ifindex is the not-exist interface, 
> > > it should be fail and the errno should be set ENODEV.
> > >   Actually, it does well(sendmsg returns on success ), because the kernel 
> > > don't check the interface。
> > 
> > This patch changes this code path to be different than most others that 
> > completely ignore the device for the unspecified address - for example 
> > inet6_bind() and rawv6_bind().  Those paths only care about the device 
> > for a link-local address, so I don't think this patch is correct.
> 
> Semantics are different.  sin6_scope_id is valid ifindex only if
> the scope is  link-local (Note: scope-id is scope-specific; 
> for example, for "site-local" addresses, the values cannot be
> directly mapped onto ifindex space).  On the other hand, ipi6_ifindex
> is always effective even if the source address is global.

2 things:
- Check if ifindex is valid is always needed, anyway.
- Check for valid address ipv6_chk_addr() should not device-specific
  if the destination (or source) is link-local (or multicast, maybe).

--yoshfuji
