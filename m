From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit
 kernels.
Date: Sat, 26 Apr 2008 13:53:37 +0900 (JST)
Message-ID: <20080426.135337.101775890.yoshfuji@linux-ipv6.org>
References: <20080426.123359.14563419.yoshfuji@linux-ipv6.org>
	<OF326F3AF9.7322F5FB-ON88257437.00174874-88257437.00194F7B@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33762 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751230AbYDZExk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2008 00:53:40 -0400
In-Reply-To: <OF326F3AF9.7322F5FB-ON88257437.00174874-88257437.00194F7B@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <OF326F3AF9.7322F5FB-ON88257437.00174874-88257437.00194F7B@us.ibm.com> (at Fri, 25 Apr 2008 21:36:29 -0700), David Stevens <dlstevens@us.ibm.com> says:

> > net/compat.c is not the right place.
> > Please put this in net/ipv4/compat.c or so.
> > Or at least, these must be guarded by CONFIG_INET.
> 
>         This code is for both v4 and v6, so I'd rather it not be in
> net/ipv4/compat.c. I didn't try without CONFIG_INET, -- will look
> at that.

We've been putting ipv4/ipv6 common things in net/ipv4/*.c,
so please put it in net/ipv4/compat.c.

> > > +struct compat_group_filter {
> > > +       __u32                            gf_interface;
> > > +       struct __kernel_sockaddr_storage gf_group
> > > +               __attribute__ ((aligned(4)));
> > > +       __u32                            gf_fmode;
> > > +       __u32                            gf_numsrc;
> > > +       struct __kernel_sockaddr_storage gf_slist[1]
> > > +               __attribute__ ((aligned(4)));
> > > +} __attribute__ ((packed));
> > > +
> > 
> > include/linux/in.n.
> 
>         I don't understand this comment. If you're suggesting I
> put these in an include file, I didn't because this is the only
> file that uses them and I don't want them to be visible to any
> other code. If you mean something else, please explain.

We put most (if not all) compat structures in headers.
Sparse definitions are not good.

--yoshfuji

