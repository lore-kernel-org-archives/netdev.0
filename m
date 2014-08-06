From: Nathan Lynch <Nathan_Lynch@mentor.com>
Subject: Re: [Regression] FEC: Panic on suspend in 3.16
Date: Wed, 6 Aug 2014 10:43:19 -0500
Message-ID: <53E24D17.90704@mentor.com>
References: <53E24147.4050304@parkeon.com> <53E24525.2020809@mentor.com> <53E24A99.2020604@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Martin Fuzzey <mfuzzey@parkeon.com>, <netdev@vger.kernel.org>,
	<festevam@gmail.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Stefano Babic <sbabic@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:57725 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753240AbaHFPnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 11:43:24 -0400
In-Reply-To: <53E24A99.2020604@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/2014 10:32 AM, Stefano Babic wrote:
> Hi Nathan, Martin,
> 
> On 06/08/2014 17:09, Nathan Lynch wrote:
>> On 08/06/2014 09:52 AM, Martin Fuzzey wrote:
>>> Hi all,
>>>
>>> I am using the fec ethernet driver on a i.MX53 SoC.
>>>
>>> All was working fine on 3.13 but, after upgrading to 3.16 I now get a
>>> panic on suspend:
>>
>> Same issue reported here:
>>
>> http://lists.infradead.org/pipermail/linux-arm-kernel/2014-August/277728.html
>>
>> a71e3c37960c (net: phy: Set the driver when registering an MDIO bus
>> device) has been implicated; try reverting that.
>>
> 
> I confirm this issue (on a i.MX35). The ndev pointer is NULL in the
> suspend function. I added the check for the pointer:

I'm not sure this is the right fix.  The fec driver's suspend function
is being called for a device it did not probe (I verified this on mx6q).

See Russell's explanation here:

http://lists.infradead.org/pipermail/linux-arm-kernel/2014-August/277823.html
