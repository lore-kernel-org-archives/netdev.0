From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH v11 5/5] powerpc: Fix up fsl-flexcan device tree binding.
Date: Wed, 10 Aug 2011 13:40:30 -0500
Message-ID: <4E42D09E.4080405@freescale.com>
References: <1312993670-23999-1-git-send-email-holt@sgi.com> <1312993670-23999-6-git-send-email-holt@sgi.com> <4E42B83C.2040705@freescale.com> <20110810171933.GW4926@sgi.com> <4E42C196.7030708@freescale.com> <20110810183016.GY4926@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Kumar Gala <galak@kernel.crashing.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	U Bhaskar-B22300 <B22300@freescale.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	<socketcan-core@lists.berlios.de>, <netdev@vger.kernel.org>,
	PPC list <linuxppc-dev@lists.ozlabs.org>,
	<devicetree-discuss@lists.ozlabs.org>
To: Robin Holt <holt@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:9403 "EHLO
	TX2EHSOBE009.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754286Ab1HJSkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2011 14:40:33 -0400
In-Reply-To: <20110810183016.GY4926@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/10/2011 01:30 PM, Robin Holt wrote:
> On Wed, Aug 10, 2011 at 12:36:22PM -0500, Scott Wood wrote:
>> On 08/10/2011 12:19 PM, Robin Holt wrote:
>>> On Wed, Aug 10, 2011 at 11:56:28AM -0500, Scott Wood wrote:
>>>> Also may want to list fsl,p1010-rdb as a "canonical compatible" for
>>>> anything which is backwards compatible with p1010's implementation.
>>>
>>> How do I specify 'canonical compatible'?
>>
>> Something like:
>>
>>   compatible: Should be "fsl,<processor>-flexcan" and "fsl,flexcan".
>>
>>   An implementation should also claim any of the following compatibles
>>   that it is fully backwards compatible with:
>>
>>   - fsl,p1010-rdb

Gah, I don't know how "rdb" replaced "flexcan" in the above.  Sorry for
any confusion.

> I am so confused.  fsl,p1010-flexcan refers, in my mind at least, to
> a particular chiplet on the p1010 freescale processor. 

It refers to a particular version of the flexcan logic, for which the
hardware doc people weren't kind enough to give us a public version number.

It has been common and recommended practice in such cases, when there
are multiple chips containing the same device, to pick a canonical chip
(such as the first one to have the device or to be supported) and have
others claim compatibility with it.

> fsl,p1010-rdb
> would mean nothing to me as that is a p1010 processor with two flexcan
> chiplets wired to a pair of DB-9 jacks.  For the driver, what additional
> information is being conveyed?

The programming model of the flexcan chiplet.

> Let's cut to the chase.  Here is what I have after incorporating your
> earlier comment about the compatible line.  Please mark this up to
> exactly what you are asking for.
> 
> Thanks,
> Robin
> ------------------------------------------------------------------------
> Flexcan CAN contoller on Freescale's ARM and PowerPC processors
> 
> Required properties:
> 
> - compatible : Should be "fsl,<processor>-flexcan" and "fsl,flexcan"

   An implementation should also claim any of the following compatibles
   that it is fully backwards compatible with:

   - fsl,p1010-flexcan

> - reg : Offset and length of the register set for this device
> - interrupts : Interrupt tuple for this device
> 
> Example:
> 
>   can@1c000 {
>           compatible = "fsl,p1010-flexcan", "fsl,flexcan";
>           reg = <0x1c000 0x1000>;
>           interrupts = <48 0x2>;
>           interrupt-parent = <&mpic>;
>   };
> 

-Scott

