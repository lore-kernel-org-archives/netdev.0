From: Fleming Andy-AFLEMING <afleming@freescale.com>
Subject: Re: [PATCH] net: Add support for handling queueing in hardware
Date: Fri, 22 Mar 2013 14:31:50 +0000
Message-ID: <A5ACC15C-361D-48E6-BFFF-9AA3966C2A68@freescale.com>
References: <E1UJ1fR-0004hs-4l@swissweb.swissdisk.com>,<20130322.101139.1942128058226201237.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130322.101139.1942128058226201237.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mar 22, 2013, at 9:11, "David Miller" <davem@davemloft.net> wrote:

> From: Andy Fleming <afleming@freescale.com>
> Date: Wed, 13 Jul 2011 08:52:04 -0500
> 
>> The QDisc code does a bunch of locking which is unnecessary if
>> you have hardware which handles all of the queueing. Add
>> support for this, and skip over all of the queueing code if
>> the feature is enabled on a given device, which breaks QDisc
>> support on dpaa_eth, and also coopts the FCOE feature bit.
>> 
>> Signed-off-by: Andy Fleming <afleming@freescale.com>
>> Signed-off-by: Ben Collins <ben.c@servergy.com>
> 
> Sorry, no.
> 
> If we are going to support something like this then there needs to
> be full coordination, configuration wise, so that if we enable
> a qdisc that the hardware supports we submit it directly, but if
> we enable a qdisc the HW does not support, we still use the software
> qdisc.
> 
> This also means that we need to have a way to determine if the qdisc
> configuration exceeds that parametorial limits of the device's HW
> capabilities, and fallback to software qdisc in those cases too.


It would appear one of our customers is attempting to upstream our code for us. We are aware that this current solution is unacceptable (which is why we have not submitted it), and we are currently trying to develop a less hacky solution that integrates with qdisc.

Andy
