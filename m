From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Software receive packet steering
Date: Mon, 20 Apr 2009 03:46:28 -0700 (PDT)
Message-ID: <20090420.034628.224469114.davem@davemloft.net>
References: <65634d660904081548g7ea3e3bfn858f2336db9a671f@mail.gmail.com>
	<87eivnpqde.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60351
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755016AbZDTKqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 06:46:36 -0400
In-Reply-To: <87eivnpqde.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Mon, 20 Apr 2009 12:32:29 +0200

> Tom Herbert <therbert@google.com> writes:
> 
>> +got_hash:
>> +	hash %= cpus_weight_nr(mask);
> 
> That looks rather heavyweight even on modern CPUs. I bet it's 40-50+ cycles
> alone forth the hweight and the division. Surely that can be done better?

The standard way to do this is to compute a 32-bit jenkins
hash, and do a 64-bit multiply of this value with a suitable
reciprocol.

This is what skb_tx_hash() is doing in net/core/dev.c
