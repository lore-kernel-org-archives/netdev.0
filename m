From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Tue, 26 Oct 2010 12:58:54 -0400
Message-ID: <4CC708CE.4040404@hp.com>
References: <AANLkTikC4pv8aOODM2pOg2bKQGL69wivcUU3f9ZziPhe@mail.gmail.com> <20101025213841.635b9a15@nehalam> <AANLkTinGpt=EQX3aXRaj5mEUMDNpyEapbs4VyOwgtN55@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:35849 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751893Ab0JZQ64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 12:58:56 -0400
In-Reply-To: <AANLkTinGpt=EQX3aXRaj5mEUMDNpyEapbs4VyOwgtN55@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/2010 01:44 AM, Lorenzo Colitti wrote:
> On Mon, Oct 25, 2010 at 9:38 PM, Stephen Hemminger
> <shemminger@vyatta.com> wrote:
>> This is incorrect. When link is lost, routes and address should not be
>> flushed. They should be marked as tentative and then go through DAD again
>> on the new network.
> 
> That won't help the case I am trying to fix, which is the case where
> the new link has a global prefix different than the old link. Marking
> the addresses as tentative will simply make them pass DAD and come
> back as soon as link comes back. But since they don't match the prefix
> that is assigned to the new link, they are unusable, because packets
> can't be routed back to them.

The old addresses will become deprecated, and eventually get removed, but
it will take 2 hours.

>> If you do it this way, you break routing protocols when link is brought
>> down and back up.
> 
> The only addresses and routes flushed in this way should be ones that
> aren't manually configured, i.e., the ones created by autoconf
> (addrconf.c:2720 onwards). These won't be used by routing protocols,
> except for link-local addresses. So I assume you're talking about
> link-local here.

I posted a very similar patch recently:

http://marc.info/?l=linux-netdev&m=128415231909522&w=2

But the first response pointed out that I didn't test this with just a
simple link flap, in which case all the IPv6 addresses are deleted,
and all sessions using them die.  Not good.  This changes the current
behavior, and isn't what happens with IPv4 either.

Having these addresses restart DAD is probably about as much as we
can do I think, unless we add a per-device sysctl to remove the addresses
(which I think has been shot-down before).  Is this a mobile device that
is actually changing it's point of attachment?

-Brian
