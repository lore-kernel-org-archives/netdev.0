From: David Miller <davem@davemloft.net>
Subject: Re: [RFC:PATCH 3.6.0-] net/ipconfig: Extend ipconfig retries to
 device open
Date: Mon, 08 Oct 2012 14:14:03 -0400 (EDT)
Message-ID: <20121008.141403.36402742873454814.davem@davemloft.net>
References: <1349365123-25826-1-git-send-email-srinivas.kandagatla@st.com>
	<20121007.001156.294004123796199582.davem@davemloft.net>
	<5072C961.3030807@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: srinivas.kandagatla@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56342 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185Ab2JHSOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 14:14:08 -0400
In-Reply-To: <5072C961.3030807@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Date: Mon, 08 Oct 2012 13:38:57 +0100

> On 07/10/12 05:11, David Miller wrote:
>> From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
>> Date: Thu,  4 Oct 2012 16:38:43 +0100
>>
>>> This patch adds retries to ipconfig at device open, the reason to do
>>> this is: Lets say If some mdio bus driver decide to use defered probe
>>> when it does not find any phys on the bus. The same mdio-bus driver is
>>> re-probed as part of lateinit calls. However ipconfig also fits into
>>> lateinit calls, so if ipconfig is called before the re-probe of mdio-bus
>>> driver, the mac driver will fail to find a valid PHY on the mdio-bus.
>> Real device drivers for real devices should not probe using late
>> initcalls.
> I agree,
> Let me summarize what I did try.
> 
> I wanted to use "Defered Probe Feature" which went in 3.4 kernel to
> solve a sequencing issue.
> So modified Mdio-driver accordingly, mdio-driver decided to defer its
> probe for the first-time when It could not detect any PHY's on the BUS.
> (second time) device probe is actually called in lateinit call sequence
> by "Defered Probe Code".

That's not how we probe "devices on a bus" which is the model you
should be following here to fix this bug.

Just delaying is going to run into corner cases where things do not
work.  You need cooperation between bus provider and bus consumer,
full stop.
