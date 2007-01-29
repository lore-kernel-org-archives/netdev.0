From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Tue, 30 Jan 2007 07:25:36 +0900 (JST)
Message-ID: <20070130.072536.129403235.yoshfuji@linux-ipv6.org>
References: <45BA75D1.6040005@hp.com>
	<20070129163447.GB21938@hmsreliant.homelinux.net>
	<20070129213013.GA26841@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, sri@us.ibm.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:47500 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932578AbXA2WYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jan 2007 17:24:23 -0500
In-Reply-To: <20070129213013.GA26841@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070129213013.GA26841@hmsreliant.homelinux.net> (at Mon, 29 Jan 2007 16:30:13 -0500), Neil Horman <nhorman@tuxdriver.com> says:

> Quick reality check here.  In thinking about how best to go about this
> redirection of frames to the default router, based on Dave M.s input, I think
> that the best solution would be in ndisc_send_ns.  What I was thinking was that
> in ndisc_send_ns, we already detect if a source address is optimistic and squash
> the transmission of the frame there.  What if in addition to that supression, we
:

Well...I think it is okay if sending NS is deferred (or omit) in
ndisc_send_ns() (or in ndisc_solicit(), probably) if the source is
optimistic address, but... I'm not sure so far if it is appropriate
from design POV. The ndisc_send_ns() nor ndisc_solicit() is not about
our current neigh state machine, at all.

I do not think we should copy neighbor information from (one of)
default routers, but use temporary neigh entry (or neigh in new state)
for such datagrams in stead.  We should aware that:

 1) default router's link-layer address may change.
 2) we may have more than one default routers.
 3) the default router's link-layer may be invalidated.

Anyway, I'm start thinking about CONFIG_IPV6_OPTIMISTIC_DAD to 
make sure the new code path will not break anything else...

--yoshfuji


