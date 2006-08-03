From: Philip Craig <philipc@snapgear.com>
Subject: Re: [RFC] gre: transparent ethernet bridging
Date: Thu, 03 Aug 2006 11:33:25 +1000
Message-ID: <44D15265.4090905@snapgear.com>
References: <44CDD631.5030008@snapgear.com> <20060731091423.3327f85e@dxpl.pdx.osdl.net> <44CEAB31.5090501@snapgear.com> <20060731220822.444f04e4@localhost.localdomain> <20060802074223.GA23715@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.snapgear.com ([203.143.235.140]:732 "EHLO cyberguard.com.au")
	by vger.kernel.org with ESMTP id S932136AbWHCBd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 21:33:26 -0400
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20060802074223.GA23715@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lennert Buytenhek wrote:
> On Mon, Jul 31, 2006 at 10:08:22PM -0700, Stephen Hemminger wrote:
> 
>>>> Why not use existing bridge code?
>>> It does use the existing bridge code.  Perhaps the name is misleading.
>>> All it does is encapsulate the full ethernet header in a gre packet,
>>> rather than only layer 3.  That is, currently gre uses ARPHRD_IPGRE,
>>> but bridging requires ARPHRD_ETHER.
>> I am not against making the bridge code smarter to handle other
>> encapsulation.
> 
> What if you want to run ethernet directly over a GRE tunnel, without
> using bridging?

But on the other hand, this method allows you to send both ethernet
and non-ethernet traffic over the same GRE tunnel.  Is that useful?
Actually, this feature is what makes the handling of the LLC_SAP_BSPAN
packets simple.

The patch to bridging is a lot cleaner than the patch to GRE, and it
also sidesteps the userspace configuration issues, so I don't want to
go back to modifying the GRE device.

Both could be achieved by creating a new virtual device that sits
between GRE and bridging.
