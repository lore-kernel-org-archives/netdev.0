From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 5/5] [powerpc] Fix up fsl-flexcan device tree binding.
Date: Tue, 9 Aug 2011 14:13:01 -0500
Message-ID: <4E4186BD.5000602@freescale.com>
References: <1312901031-29887-1-git-send-email-holt@sgi.com> <1312901031-29887-6-git-send-email-holt@sgi.com> <4E4179CB.6030101@freescale.com> <20110809184524.GB4926@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>,
	U Bhaskar-B22300 <B22300@freescale.com>,
	<netdev@vger.kernel.org>, <socketcan-core@lists.berlios.de>,
	PPC list <linuxppc-dev@lists.ozlabs.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>
To: Robin Holt <holt@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe003.messaging.microsoft.com ([213.199.154.141]:48382
	"EHLO DB3EHSOBE003.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752294Ab1HITNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 15:13:08 -0400
In-Reply-To: <20110809184524.GB4926@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/09/2011 01:45 PM, Robin Holt wrote:
> On Tue, Aug 09, 2011 at 01:17:47PM -0500, Scott Wood wrote:
>> On 08/09/2011 09:43 AM, Robin Holt wrote:
>>> In working with the socketcan developers, we have come to the conclusion
>>> the fsl-flexcan device tree bindings need to be cleaned up. 
>>> The driver does not depend upon any properties other than the required properties
>>> so we are removing the file.
>>
>> That is not the criterion for whether something should be expresed in
>> the device tree.  It's a description of the hardware, not a Linux driver
>> configuration file.  If there are integration parameters that can not be
>> inferred from "this is FSL flexcan v1.0", they should be expressed in
>> the node.
> 
> There are no properties other than the required properties.  The others
> were wrongly introduced and are not needed by the driver.

Not needed by this driver, or will never be needed by any reasonable
driver (or is not a good description of the hardware)?

The device tree is not an internal Linux implementation detail.  It is
shared by other OSes, firmwares, hypervisors, etc.  Bindings should be
created with care, and kept stable unless there's a good reason to break
compatibility.

devicetree-discuss@lists.ozlabs.org should be CCed on device tree
discussions.

> When we
> removed the other properties and the wrong documentation of the mscan
> oscillator source in the fsl-flexcan.txt file, we were left with an
> Example: section and a one-line statement "The only properties supported
> are the required properties."  That seemed like the fsl-flexcan.txt
> file was then pointless.

There is the compatible string, and you could mention that there is a
single reg resource and a single interrupt.

>> Removing the binding altogether seems extreme as well -- we should have
>> bindings for all devices, even if there are no special properties.
> 
> Ok.  I can do that too.  Who is the definitive source for that answer?

For policy questions on device tree bindings?  Grant Likely is the
maintainer for device tree stuff.

A lot of the simpler bindings have been left undocumented so far, IMHO
it should be a goal to document them all.  There are some existing ones
that are documented despite not having special properties, e.g.
Documentation/devicetree/bindings/serio/altera_ps2.txt,
Documentation/devicetree/bindings/arm/sirf.txt,
Documentation/devicetree/bindings/powerpc/nintendo/wii.txt, etc.

> I assume we are talking about the fsl-flexcan.txt file when we say
> binding.  Is that correct?

Yes, although devicetree.org is another possibility.

>>> Additionally, the p1010*dts files are not
>>> following the standard for node naming in that they have a trailing -v1.0.
>>
>> What "standard for node naming"?  There's nothing wrong with putting a
> 
> For the answer to that, you will need to ask Wolfgang Grandegger.  I was
> working from his feedback.  Looking at the plethora of other node names,
> the vast majority do not have any -v#.#, and the ones that do also tend
> to have multiple versions. Based upon that, I suspect he is correct,
> but I do not know where the documentation is or if it even exists.

There's a lot of crap in old bindings, plus it's not appropriate for all
circumstances (specifying bindings should be done a little more
carefully than "what do most other bindings do?").  It's something we've
been doing lately for blocks that have a version number, but it's not
dynamically readable.

Looking in the FlexCAN chapter of the p1010 manual, I don't see any
reference to a block version, and I do see references to "previous
FlexCAN versions".  So I suggest "fsl,p1010-flexcan".

-Scott

