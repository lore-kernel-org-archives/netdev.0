From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] openvswitch: properly refcount vport-vxlan
 module
Date: Tue, 01 Dec 2015 14:26:28 -0500 (EST)
Message-ID: <20151201.142628.2000130498641931177.davem@davemloft.net>
References: <1448971437.3330290.454583417.56E794A4@webmail.messagingengine.com>
	<1448975955.4459.4.camel@redhat.com>
	<1448984508.3380707.454779977.1FF45EA1@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pabeni@redhat.com, netdev@vger.kernel.org, pshelar@nicira.com,
	tgraf@suug.ch
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56126 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931AbbLAT0b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 14:26:31 -0500
In-Reply-To: <1448984508.3380707.454779977.1FF45EA1@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 01 Dec 2015 16:41:48 +0100

> On Tue, Dec 1, 2015, at 14:19, Paolo Abeni wrote:
>> Currently all the vport_ops list manipulation functions are protected by
>> the ovs_lock (even the lookup): the scenario described above should not
>> be possible.
> 
> This makes all sense and it seems no use-after-free is possible at all
> (I didn't notice the lookup path takes the lock). But the macro still
> looks ugly and modifies a global struct with a per-module linked symbol.
> David, why exactly didn't you like the first patch? Seems to me it does
> what is actually needed.

Because it is error prone.

I want it hidden quietly and reliably in a macro, just like we do for
other similar cases across the tree.

The caller of the registry functions has no reason to be concerned
with these details if we can take care of it transparently.
