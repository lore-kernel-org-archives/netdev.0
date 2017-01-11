From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv6: put autoconf routes into
 per-interface tables
Date: Wed, 11 Jan 2017 09:11:39 -0500 (EST)
Message-ID: <20170111.091139.1754139535517451753.davem@davemloft.net>
References: <bbcab8bb-6a2a-6b90-f6a2-ad840a2c389c@cumulusnetworks.com>
        <un3fkd-lod.ln1@banana.localnet>
        <CAKD1Yr3nfOp1LNfvVuTGZyThwu8Z+gaSN-DVaa11ZJYR+tMemg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: temnota.am@gmail.com, netdev@vger.kernel.org
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49212 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932441AbdAKOLp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 09:11:45 -0500
In-Reply-To: <CAKD1Yr3nfOp1LNfvVuTGZyThwu8Z+gaSN-DVaa11ZJYR+tMemg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Wed, 11 Jan 2017 02:47:55 +0900

> On Tue, Jan 10, 2017 at 10:21 PM, Andrey Jr. Melnikov
> <temnota.am@gmail.com> wrote:
>>
>> > >>> I have no firsthand experience of this myself, but if the problems
>> > >>> that Andrey reports above in this thread are real, then those would
>> > >>> indicate that the code is not well-supported. Being unable to accept
>> > >>> DAD is a pretty serious issue. Andrey, what version of the kernel did
>> > >>> you see this on?
>>
>> Good catch. I'm running 4.8 without this patch. Current 4.10-rc works. Sorry
>> for noise.
> 
> Ack. As I said before, I haven't seen this myself. Shouldn't have made
> assertions without firsthand evidence.
> 
> That said, I think this patch is useful even though autoconf on VRFs
> works the same way. One reason is the example I provided above: it
> works even for interfaces that don't exist yet, whereas a VRF has to
> be created ahead of time, which means that the interface cannot
> immediately come up and receive an RA or its configuration will be
> incorrect.
> 
> I also think that from a configuration perspective it's not
> necessarily useful to have one VRF for every interface, but that sort
> of depends on your point of view. Perhaps it's fine on a client system
> to have both vrf-wlan0 and wlan0, and vrf-eth0 and eth0. That might be
> confusing to users but maybe users don't really care?
> 
> More in general I think that using a VRFs is buying into a bigger set
> of assumptions/restrictions than this patch does. For example, if I'm
> reading ipv6_dev_get_saddr correctly, once you put an interface in a
> VRF you can't really use the weak host model any more, because the
> stack won't pick a source address from outside the VRF if the route
> lookup returned a route in the VRF. Turning on the functionality in
> patch is a more minimal change that only affects autoconf.

I understand what you're saying, but if you look at how apps can be
put into hierarchical control groups, and automatically bind to VRF's
based upon where they are in that cgroup hierarchy, it matches your
use case precisely.

Maybe the setup is not ideal, but architectually it does everything
you want.  And we strongly try to avoid adding multiple ways to do the
same thing.
