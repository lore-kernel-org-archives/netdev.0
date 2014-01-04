From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2 v2 0/2] add support for IFA_F_MANAGETEMPADDR
Date: Sat, 4 Jan 2014 12:05:57 +0100
Message-ID: <20140104110557.GD9295@minipsycho.orion>
References: <1388676879-2603-1-git-send-email-jiri@resnulli.us>
 <20140102172949.GF22494@order.stressinduktion.org>
 <20140104104331.GB9295@minipsycho.orion>
 <20140104105515.GA25828@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, stephen@networkplumber.org,
	thaller@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:46890 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161AbaADLGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 06:06:00 -0500
Received: by mail-ea0-f182.google.com with SMTP id a15so7160661eae.27
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 03:05:59 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20140104105515.GA25828@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Jan 04, 2014 at 11:55:15AM CET, hannes@stressinduktion.org wrote:
>On Sat, Jan 04, 2014 at 11:43:31AM +0100, Jiri Pirko wrote:
>> Thu, Jan 02, 2014 at 06:29:49PM CET, hannes@stressinduktion.org wrote:
>> >On Thu, Jan 02, 2014 at 04:34:37PM +0100, Jiri Pirko wrote:
>> >> v1->v2: Removed 0xff masking of ifa_flags
>> >> 
>> >> Jiri Pirko (2):
>> >>   add support for extended ifa_flags
>> >>   add support for IFA_F_MANAGETEMPADDR
>> >> 
>> >>  include/linux/if_addr.h |  2 ++
>> >>  ip/ipaddress.c          | 50 +++++++++++++++++++++++++++++++++++--------------
>> >>  2 files changed, 38 insertions(+), 14 deletions(-)
>> >
>> >I still wonder how source address selection should work for
>> >IFA_F_MANAGETEMPADDR if use_tempaddr != 2 mode is not available for
>> >those addresses.
>> >
>> >Up until now applications can bind to those addresses and traffic can be
>> >received for them, but there is now way how a user can specify to favor them
>> >in case of use_tempaddr == 0.
>> 
>> I'm not sure I understand you. Can you please elaborate more? Not sure
>> how this is related to iproute2.
>
>Sorry, it is not related to this patch set at all but more to
>IFA_F_MANAGETEMPADDR as a whole (maybe it could be a follow-up feature).
>
>> Anyway, the kernel behaviour wrt use_tempaddr settings remains unchanged
>> with the addition of IFA_F_MANAGETEMPADDR. It only allows to create temp
>> addresses for other addresses than the ones created by kernel (by RA).
>
>I assume that systems with NetworkManager won't activate use_tempaddr. If
>you look at ipv6_get_saddr_eval we only prefer privacy addresses to
>normal ones, if use_tempaddr == 2, which also implies that kernel does
>generate privacy addresses.

Sure. NM should set use_tempaddr accordingly. You are right that kernel
generate temporary adresses, but only for the prefixes received via
neighbor discovery (see addrconf_prefix_rcv). The ones that are set by
hand are not handled. That is the reason we introduced IFA_F_MANAGETEMPADDR.

>
>So currently privacy addresses are correctly installed, but we cannot control
>if we want prefer them to global addresses for outgoing connections where the
>socket is not bound to a specific address.
>
>Also, I saw that NetworkManager switched to install autoconf addresses
>as /128, doesn't this break with IFA_F_MANAGETEMPADDR, as you expect a /64
>prefixlen?

/64 is required

>
>I guess NetworkManager wants a way to add /64 addresses without installing the
>on-link prefix route?
>
>Hope that makes sense?
>
>Greetings,
>
>  Hannes
>
