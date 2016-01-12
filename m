From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] ifb: make device count build-time configurable
Date: Tue, 12 Jan 2016 15:54:40 -0500 (EST)
Message-ID: <20160112.155440.538873882796833417.davem@davemloft.net>
References: <1452599804-27284-1-git-send-email-lkundrak@v3.sk>
	<5694F7BA.3040402@mojatatu.com>
	<20160112104437.0e1a841b@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, lkundrak@v3.sk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53965 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754102AbcALUym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 15:54:42 -0500
In-Reply-To: <20160112104437.0e1a841b@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 12 Jan 2016 10:44:37 -0800

> On Tue, 12 Jan 2016 07:55:22 -0500
> Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> 
>> On 16-01-12 06:56 AM, Lubomir Rintel wrote:
>> > The devices can be created at run-time for quite some time already and the
>> > load-time device creation collides with attempts to create the device of
>> > the same name:
>> >
>> >    # rmmod ifb
>> >    # ip link add ifb0 type ifb
>> >    RTNETLINK answers: File exists
>> >
>> > This is pretty much the same situation as was with the block loop devices
>> > which was solved by adding a build-time configuration that the
>> > distributions could use as they deem fit while keeping the default for
>> > compatibility.
>> >
>> > Let's do that here as well.
>> >
>> > Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>
>> 
>> I guess module options are frowned upon. so:
> 
> I would prefer that this were done with a module parameter, the same as dummy.
> Only developers build their own configured kernels. Having the value set later
> at module load time is preferable.

I like this even less, it means tools behave significantly differently
based upon what module options were passed to the kernel.

Module options really should not change kernel behavior like this..
