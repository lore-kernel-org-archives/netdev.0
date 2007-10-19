From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: multicast: bug or "feature"
Date: Fri, 19 Oct 2007 12:49:50 -0400
Message-ID: <4718E02E.1080603@hp.com>
References: <OFDA173EE1.60049F6E-ON88257379.0052A408-88257379.00544DA0@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, brian.haley@hp.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:44038 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760694AbXJSQuX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 12:50:23 -0400
In-Reply-To: <OFDA173EE1.60049F6E-ON88257379.0052A408-88257379.00544DA0@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Stevens wrote:
> netdev-owner@vger.kernel.org wrote on 10/19/2007 04:43:27 AM:
> 
>> Vlad Yasevich <vladislav.yasevich@hp.com> wrote:
>>> Now, to figure out what IPv6 does different and why it works.
>>> Seems to me that the two should have the same behavior.
>> IPv6 on Linux uses a per-interface addressing model as opposed
>> to the per-host model used by IPv4.
> 
>         For link-local addresses, yes.
> 
>         It's really a security feature; the ordinary
> case where you'd receive something on an interface that's
> using one of your source addresses is when someone is spoofing
> you, has a duplicate address, or maybe an (unintentional)
> routing loop. All of those are error cases, so dropping a
> received packet that claims to be sent by you is a reasonable
> thing to do.

I can see this as a good feature for unicast, but starting to
doubt it just a little bit for multicast.  With IGMPv3/MLDv2 and source
filtering, this could be done as a filter on individual sockets.

The problem them becomes IGMPv2 and MLDv1.

>         If you're getting link-local source addresses for your
> IPv6 multicast packets, that may explain it. The link-local
> addresses are required to be unique and valid only for that
> link, so IPv6 should not consider a different interface's
> link-local address as "local" for a destination address, or
> a packet using that source address as bogus.

Looks like the only time IPv6 does any type of source filtering
is when CONFIG_IPV6_MULTIPLE_TABLES is turned on.

I need to turn this on and see if I get the same results or not.

>         For a global address, v4 and v6 use the same rules--
> for a destination you can receive it on any interface for
> any global address. So, if your source address was a global
> IPv6 address and it worked, I'd guess IPv6 just isn't checking
> the source address. I don't know that it's required by RFC for
> either v4 or v6, though it's probably a good idea.

I've reproduced the multicast traffic using both global and link-local
addresses (both source and destination were of the same scope in the
tests, i.e. either global or link-local).

So, it appears that IPv6 didn't do any source verification for multicast
traffic.

-vlad
