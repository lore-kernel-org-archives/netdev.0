From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch iproute2 v2 0/2] add support for IFA_F_MANAGETEMPADDR
Date: Sat, 4 Jan 2014 12:15:46 +0100
Message-ID: <20140104111546.GB25828@order.stressinduktion.org>
References: <1388676879-2603-1-git-send-email-jiri@resnulli.us> <20140102172949.GF22494@order.stressinduktion.org> <20140104104331.GB9295@minipsycho.orion> <20140104105515.GA25828@order.stressinduktion.org> <20140104110557.GD9295@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	thaller@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:38671 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822AbaADLPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 06:15:47 -0500
Content-Disposition: inline
In-Reply-To: <20140104110557.GD9295@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 04, 2014 at 12:05:57PM +0100, Jiri Pirko wrote:
> Sure. NM should set use_tempaddr accordingly. You are right that kernel
> generate temporary adresses, but only for the prefixes received via
> neighbor discovery (see addrconf_prefix_rcv). The ones that are set by
> hand are not handled. That is the reason we introduced IFA_F_MANAGETEMPADDR.

Ah, sorry. So NM sets use_tempaddr == 2 but disables accept_ra? That's fine,
sorry to bother!

> >So currently privacy addresses are correctly installed, but we cannot control
> >if we want prefer them to global addresses for outgoing connections where the
> >socket is not bound to a specific address.
> >
> >Also, I saw that NetworkManager switched to install autoconf addresses
> >as /128, doesn't this break with IFA_F_MANAGETEMPADDR, as you expect a /64
> >prefixlen?
> 
> /64 is required

Ok, currently NM seems to "violate" that as it installs autoconf addresses
with 128 prefixlen, so IFA_F_MANAGETEMPADDR should not work on them.
(currently observed on Fedora 20).

Greetings,

  Hannes
