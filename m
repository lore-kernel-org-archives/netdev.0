From: David Miller <davem@davemloft.net>
Subject: Re: [net-next.git 0/9] stmmac: update to March_2013 (adding PTP &
 RGMII/SGMII)
Date: Fri, 08 Mar 2013 11:22:19 -0500 (EST)
Message-ID: <20130308.112219.1999774630969953487.davem@davemloft.net>
References: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
	<20130307.153456.83724032858548621.davem@davemloft.net>
	<51399048.3070505@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bh74.an@samsung.com,
	rayagond@vayavyalabs.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56090 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933517Ab3CHQWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 11:22:23 -0500
In-Reply-To: <51399048.3070505@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Fri, 08 Mar 2013 08:16:24 +0100

> Hello David
> 
> On 3/7/2013 9:34 PM, David Miller wrote:
>> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
>> Date: Thu,  7 Mar 2013 11:50:10 +0100
>>
>>> The PTP support is quite intrusive because it needs to support the
>>> extended
>>> descriptors used for saving the HW timestamps.
>>> These are available in new chip generations, only.
>>> So we have actually found useful to use some Kconfig options to
>>> surround PTP and extended descriptor support. This approach helped on
>>> old platform (embeeded system) where PTP is not supported and where we
>>> do not want to pay extra code and check in critical rx/tx paths.
>>
>> I would prefer run time handling of all of this.
>>
>> You do not need to put extra checks in the fast paths, instead you
>> have different methods that get hooked up into the netdev_ops
>> based upon chip capabilities/features/mode.
 ...
> Welcome advice.

Exactly what I told you above.  You have two sets of routines,
one that deal with the older descriptors and one set that deals
with the new descriptors that can do PTP.

And you hook up different interrupt handler, NAPI poll, and
netdev_ops based upon the chip's capabilities.

You need no runtime testing, only a test a probe time to setup
things up properly.

What is so hard about this to understand?
