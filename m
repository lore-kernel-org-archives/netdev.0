From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 6/8] ipv4: fib: Add an API to request a FIB
 dump
Date: Thu, 17 Nov 2016 13:16:09 -0500 (EST)
Message-ID: <20161117.131609.164578639844581895.davem@davemloft.net>
References: <e2e0eaaf-30f0-e825-29c7-920115742301@stressinduktion.org>
        <20161117.114529.1851585222876647915.davem@davemloft.net>
        <f58c008f-c23a-4950-2975-3c1b4c3b8692@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: idosch@idosch.org, jiri@resnulli.us, netdev@vger.kernel.org,
        idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
        nogahf@mellanox.com, arkadis@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, dsa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, andy@greyhouse.net,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40890 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752233AbcKQS1F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 13:27:05 -0500
In-Reply-To: <f58c008f-c23a-4950-2975-3c1b4c3b8692@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 17 Nov 2016 18:20:39 +0100

> Hi,
> 
> On 17.11.2016 17:45, David Miller wrote:
>> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Date: Thu, 17 Nov 2016 15:36:48 +0100
>> 
>>> The other way is the journal idea I had, which uses an rb-tree with
>>> timestamps as keys (can be lamport timestamps). You insert into the tree
>>> until the dump is finished and use it as queue later to shuffle stuff
>>> into the hardware.
>> 
>> If you have this "place" where pending inserts are stored, you have
>> a policy decision to make.
>> 
>> First of all what do other lookups see when there are pending entires?
> 
> I think this is a problem with the current approach already, as the
> delayed work queue already postpones the insert for an undecidable
> amount of time (and reorders depending on which CPU the entry was
> inserted and the fib notifier was called).
> 
> For user space queries we would still query the in-kernel table.

Ok, I think I might misunderstand something.

What is going into this journal exactly?  The actual full software and
hardware insert operation, or just the notification to the hardware
device driver notifiers?

The "lookup" I'm mostly concerned with is the fast path where the
packets being processed actually look up a route.

I do not think we can return success on the insert to the user yet
have the route lookup dataplace not return that route on a lookup.
