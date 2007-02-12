From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Tue, 13 Feb 2007 08:27:59 +0900 (JST)
Message-ID: <20070213.082759.69474746.yoshfuji@linux-ipv6.org>
References: <20070207205503.GB20804@hmsreliant.homelinux.net>
	<20070208.065206.107341055.yoshfuji@linux-ipv6.org>
	<20070208130715.GA27267@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, sri@us.ibm.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:54487 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030494AbXBLX17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 18:27:59 -0500
In-Reply-To: <20070208130715.GA27267@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070208130715.GA27267@hmsreliant.homelinux.net> (at Thu, 8 Feb 2007 08:07:15 -0500), Neil Horman <nhorman@tuxdriver.com> says:

> > I still have a question.  Now, who will install the kernel route for
> > the incoming packet?  Can we get packet for our unicast address during
> > optimistic DAD period?
> > 
> Not sure what you're getting at here.  RFC 4429 makes no distinction between
> optimistic and non-optimistic packets for recevied frames, so routes for
> received packets will be added by the same code that does it currently (which I
> admittedly haven't looked into to closely).  Packets received for our unicast
> address (even if it is optimistic) are handled just as any other packet is (same
> as it is for TENTATIVE addresses, as I understand it). 

I think it is clear.

In tentative state, we do not receive any packet.
After finishind DAD process, we install kernel route for that address
in net/ipv6/addrconf.c:__ipv6_ifa_notify(), and we start receiving
packet for that address.

On the other hand, optimistic addresses are like in deprecated state.
So, we should be able to receive frames for those addresses.

--yoshfuji
