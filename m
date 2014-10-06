From: David Miller <davem@davemloft.net>
Subject: Re: [net 0/8] gianfar: ARM port driver updates (1/2)
Date: Mon, 06 Oct 2014 15:07:33 -0400 (EDT)
Message-ID: <20141006.150733.173099081334515077.davem@davemloft.net>
References: <1412352169-14414-1-git-send-email-claudiu.manoil@freescale.com>
	<20141005.212722.1867743289839811370.davem@davemloft.net>
	<54324AFE.1040803@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Li.Xiubo@freescale.com,
	Shruti@freescale.com
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37099 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753063AbaJFTHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 15:07:36 -0400
In-Reply-To: <54324AFE.1040803@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Mon, 6 Oct 2014 10:55:42 +0300

> On 10/6/2014 4:27 AM, David Miller wrote:
>> From: Claudiu Manoil <claudiu.manoil@freescale.com>
>> Date: Fri, 3 Oct 2014 19:02:41 +0300
>>
>>> This is the first round of driver protability fixes and clean-up
>>> with the main purpose to make gianfar portable on ARM, for the ARM
>>> based SoC that integrates the eTSEC ethernet controller - "ls1021a".
>>> The patches primarily address compile time errors, when compiling
>>> gianfar on ARM.  They replace PPC specific functions and macros
>>> with architecture independent ones, solve arch specific header
>>> inclusions, guard code that relates to PPC only, and even address
>>> some simple endianess issues (see MAC address setup patch).
>>> The patches addressing the bulk of remaining endianess issues,
>>> like handling DMA fields (BD and FCB), will follow with the sencond
>>> round.
>>> These patches were verified on the ls1021a SoC.
>>
>> If more endianness fixes are necessary and "will follow with the
>> second round", I do not see how you could have verified specifically
>> these changes on the ls1021a.
>>
> 
> Hi David,
> 
> What I did is to split the initial patchset in 2, to ease up the
> review
> process.
> This first part is fairly straightforward, these patches make
> localized
> code changes and can be more easily ported among different kernel
> versions.  The second part has fewer patches but touches more code,
> because it handles endianess conversions for all the reads/writes to
> the buffer descriptors.  Please let me now if you have objections to
> this approach.
> As for testing, we have our internal kernel tree for ARM supporting
> ls1021a, and these gianfar patches have been there for a while and
> tested.  Now it's time to upstream (a cleaned-up version of) them.
> (see git.freescale.com/git/cgit.cgi/layerscape/ls1021a/linux.git/)
> Please note that the current (upstream) net tree does not include the
> support for ls1021a (which is to be propagated via the arm tree).

I'm merely saying that it's inaccurate to say that you "verified" this
specific patch series on that chip, when in fact the second upcoming
series is necessary as well for the driver to work on that chip properly.
