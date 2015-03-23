From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: Using a waiting MDIO does not go well with a spinlocked bridge
Date: Mon, 23 Mar 2015 11:37:32 -0700
Message-ID: <CAE4R7bC34kpgfd0CcewrJ+JmKOxv4py4xL1_OZubcGEL=O28ug@mail.gmail.com>
References: <alpine.LNX.2.03.1503201321050.27020@hellgate.skynet>
	<CAE4R7bA4pzSrZfn1W198kMKnYeJEofLsrgPzq_8xJR7KjCewPg@mail.gmail.com>
	<alpine.LNX.2.03.1503231641440.21270@hellgate.skynet>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
To: Jonas Johansson <jonasj76@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:35228 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752221AbbCWSho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 14:37:44 -0400
Received: by qgf74 with SMTP id 74so32812989qgf.2
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 11:37:43 -0700 (PDT)
In-Reply-To: <alpine.LNX.2.03.1503231641440.21270@hellgate.skynet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 23, 2015 at 8:42 AM, Jonas Johansson <jonasj76@gmail.com> wrote:
>
>
> On Fri, 20 Mar 2015, Scott Feldman wrote:
>
>> On Fri, Mar 20, 2015 at 5:22 AM, Jonas Johansson <jonasj76@gmail.com>
>> wrote:
[cut]
>> I think we need to hook switchdev in fdb_delete(), then it'll get
>> called from flush and ageing out operations, rather than adding a new
>> switch_flush().  But, that's an aside for your main issue that the
>> bridge will hold a spinlock for most (all?) FDB delete operations.  I
>> don't see a way around relaxing that, on the bridge side, since it's
>> doing things like walking lists while deleting list elements.  So that
>> means the call into switchdev will be spinlocked, so switchdev driver
>> needs to deal with that.  Scheduling to work queue is one option, as
>> you mention, if FDB delete can't be done under the spinlock.
>>
>>
> Thanks for the input.
> My idea of using a switch_flush() was to take advantage of the HW to flush
> all FDB entries in one single operation. If I'm not mistaken, using
> fdb_delete() will result in a call for each FDB entry, which will result in
> a lot of overhead.

Let's get the most general case working (delete of a single FDB entry)
and then add optimizations later, if needed.  I suspect, for drivers
doing deletes atomically, the overhead is negligible, and for drivers
doing deferred deletes, again the overhead would be negligible.

-scott
