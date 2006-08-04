From: Philip Craig <philipc@snapgear.com>
Subject: Re: [RFC] gre: transparent ethernet bridging
Date: Fri, 04 Aug 2006 11:00:55 +1000
Message-ID: <44D29C47.6080407@snapgear.com>
References: <44CDD631.5030008@snapgear.com> <20060731091423.3327f85e@dxpl.pdx.osdl.net> <44CEAB31.5090501@snapgear.com> <20060731220822.444f04e4@localhost.localdomain> <20060802074223.GA23715@xi.wantstofly.org> <44D15265.4090905@snapgear.com> <20060803073307.GA29775@xi.wantstofly.org> <44D1BE93.1080308@snapgear.com> <20060803194016.GC527@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.snapgear.com ([203.143.235.140]:56034 "EHLO
	cyberguard.com.au") by vger.kernel.org with ESMTP id S1030266AbWHDBBK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 21:01:10 -0400
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20060803194016.GC527@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lennert Buytenhek wrote:
> On Thu, Aug 03, 2006 at 07:14:59PM +1000, Philip Craig wrote:
> 
>>> So now you _need_ bridging in the middle to send ethernet traffic over
>>> a GRE tunnel?  Ugh.
>> Agreed that would not be nice.  What is the usage scenario for this?
>> At least one end of the tunnel will be bridged?
> 
> For example for VPN purposes, I could imagine that you wouldn't want
> to use bridging.

What is the purpose of including the ethernet header if it only exists
on the tunnel?  I have used GRE tunnels for VPNs, but they have always
needed bridging.  If I don't need bridging, then the VPN is only passing
IP traffic and I just send that without GRE at all.

>>> If you really want to send ethernet and non-ethernet traffic over the
>>> same tunnel, can't you make multiple devices?
>> Do you mean make multiple GRE devices, where one has an ethernet mode set?
> 
> For example.  If you want to send ethernet-encapsulated and other-protocol-
> encapsulated traffic over the same GRE tunnel, that would seem like the
> cleanest solution to me.

It is fine for sending, but when receiving, which packets go to which
device?  Does a packet appear on only one device when sending, but both
devices when receiving?  Or does the operation of the non-ethernet device
change based on whether an ethernet device exists?  Modifying GRE to handle
multiple GRE tunnels that are actually the same does not seem clean.

This seems cleaner to me:
The GRE tunnel receives a packet of any protocol (ethernet included),
and adds the IP/GRE header.  Anything else is done above GRE.
Whatever needs the ethernet header should add it.

And then the decision is, how do we add the ethernet header?
- an option to GRE to always add the ethernet header
- a new virtual device
- as part of bridging

Any of these will work for me.

> Hmm, so it depends on the device whether BPDUs are sent with or without
> an ethernet header?  Do the devices that send BPDUs without ethernet
> header at least accept a BPDU with an ethernet header (and vice versa),
> or aren't the two modes compatible at all?

I don't have any to test with currently, but we only had complaints about
us not receiving them, and only at some sites.  So I assume that devices
can accept either format.

