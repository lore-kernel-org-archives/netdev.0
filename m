From: David Miller <davem@davemloft.net>
Subject: Re: Ethtool question
Date: Wed, 11 Oct 2017 13:49:19 -0700 (PDT)
Message-ID: <20171011.134919.321292333200236097.davem@davemloft.net>
References: <492e57b2-ac0a-ff01-2698-e048e97d8e37@candelatech.com>
        <20171011204406.GC30940@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36316 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752299AbdJKUtU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 16:49:20 -0400
In-Reply-To: <20171011204406.GC30940@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 11 Oct 2017 16:44:07 -0400

> On Wed, Oct 11, 2017 at 09:51:56AM -0700, Ben Greear wrote:
>> I noticed today that setting some ethtool settings to the same value
>> returns an error code.  I would think this should silently return
>> success instead?  Makes it easier to call it from scripts this way:
>> 
>> [root@lf0313-6477 lanforge]# ethtool -L eth3 combined 1
>> combined unmodified, ignoring
>> no channel parameters changed, aborting
>> current values: tx 0 rx 0 other 1 combined 1
>> [root@lf0313-6477 lanforge]# echo $?
>> 1
> 
> I just had this discussion a couple of months ago with someone. My
> initial feeling was like you, a no-op is not a failure. But someone
> convinced me otherwise...I will now endeavour to remember who that
> was and how they convinced me...
> 
> Anyone else have input here?

I guess this usually happens when drivers don't support changing the
settings at all.  So they just make their ethtool operation for the
'set' always return an error.

We could have a generic ethtool helper that does "get" and then if the
"set" request is identical just return zero.

But from another perspective, the error returned from the "set" in this
situation also indicates to the user that the driver does not support
the "set" operation which has value and meaning in and of itself.  And
we'd lose that with the given suggestion.
