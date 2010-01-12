From: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
Subject: Re: [PATCH] ipv4: add DiffServ priority based routing
Date: Tue, 12 Jan 2010 13:33:05 -0800
Message-ID: <4B4CEA91.3070201@redfish-solutions.com>
References: <201001121432.43301.schmto@hrz.tu-chemnitz.de>	<20100112.121607.39835310.davem@davemloft.net>	<4B4CE2B8.1040702@redfish-solutions.com> <20100112.130355.144803575.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: torsten.schmidt@s2006.tu-chemnitz.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:54097 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750757Ab0ALVdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 16:33:11 -0500
In-Reply-To: <20100112.130355.144803575.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2010 01:03 PM, David Miller wrote:
> From: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
> Date: Tue, 12 Jan 2010 12:59:36 -0800
> 
>> What has changed is how network equipment is required to interpret
>> the meaning of those bits.
>>
>> Even if we pass the bits "as is" to the network, if the network is
>> applying entirely new semantics (and when I say "entirely new", I
>> mean those mandated since 1998), then compatibility in the host
>> kernel API doesn't matter a hoot since the packets will still be
>> handled by every transited router according to the modern semantics.
> 
> People really don't assign global meaning to bits set by applications
> in the TOS field.

Since I'm not a clairvoyant, I can't speak for "people".  But I will say that I do assign such a meaning, and based on that interpretation, other people have code reviewed patches and accepted them, so at least "some people" share my interpretation.

I've submitted QoS fixes for NTP, Proftp, Cyrus, Apache/apr, Sendmail, CURL, Thunderbird, Firefox, and a several other packages.

All of which very much depend on host compliance with RFC-2474 and 2597/2598.


> What they do is they have a set of semantics inside of their cloud of
> routers and switch points for diffserv, and when packets come in the
> TOS field is rewritten to whatever scheme is being used inside of that
> cloud.

Uh, no.  Net Neutrality very much requires consistent end-to-end interpretation of ToS bits by backbone carriers.  If you know of a carrier that isn't honoring ToS bits, I have a group of lawyers I'd like them to meet.


> And the diffserv bits only have meaning and effect within that cloud.

Have you read RFC-2474 lately?  You only need to get as far as the Abstract:

   The services may be either end-to-end or intra-domain; they include
   both those that can satisfy quantitative performance requirements (e.g.,
   peak bandwidth) and those based on relative performance (e.g., "class"
   differentiation).

"end-to-end"... seems pretty clear to me.


> So really, having a syscall that sets the TOS bits exactly by
> applications is just fine.
> 
> People are doing diffserv right now with Linux and have done so
> for years.

Right, and I suspect in most cases, the default behavior of the host is to misinterpret the bits and put the packet in the wrong output queue.

-Philip
