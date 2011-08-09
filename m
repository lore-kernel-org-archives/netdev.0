From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH 5/5] [powerpc] Fix up fsl-flexcan device tree binding.
Date: Tue, 09 Aug 2011 21:49:01 +0200
Message-ID: <4E418F2D.4060504@grandegger.com>
References: <1312901031-29887-1-git-send-email-holt@sgi.com>
	<1312901031-29887-6-git-send-email-holt@sgi.com>
	<4E4179CB.6030101@freescale.com> <20110809184524.GB4926@sgi.com>
	<4E4186BD.5000602@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org"
	<devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
To: Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4E4186BD.5000602-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/09/2011 09:13 PM, Scott Wood wrote:
> On 08/09/2011 01:45 PM, Robin Holt wrote:
>> On Tue, Aug 09, 2011 at 01:17:47PM -0500, Scott Wood wrote:
>>> On 08/09/2011 09:43 AM, Robin Holt wrote:
>>>> In working with the socketcan developers, we have come to the conclusion
>>>> the fsl-flexcan device tree bindings need to be cleaned up. 
>>>> The driver does not depend upon any properties other than the required properties
>>>> so we are removing the file.
>>>
>>> That is not the criterion for whether something should be expresed in
>>> the device tree.  It's a description of the hardware, not a Linux driver
>>> configuration file.  If there are integration parameters that can not be
>>> inferred from "this is FSL flexcan v1.0", they should be expressed in
>>> the node.
>>
>> There are no properties other than the required properties.  The others
>> were wrongly introduced and are not needed by the driver.
> 
> Not needed by this driver, or will never be needed by any reasonable
> driver (or is not a good description of the hardware)?
> 
> The device tree is not an internal Linux implementation detail.  It is
> shared by other OSes, firmwares, hypervisors, etc.  Bindings should be
> created with care, and kept stable unless there's a good reason to break
> compatibility.
> 
> devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org should be CCed on device tree
> discussions.

Yes. The doc for the bindings we speak about

http://lxr.linux.no/#linux+v3.0.1/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt

sneaked into the kernel without been presented on any mailing list and
without the corresponding driver patch.

>> When we
>> removed the other properties and the wrong documentation of the mscan
>> oscillator source in the fsl-flexcan.txt file, we were left with an
>> Example: section and a one-line statement "The only properties supported
>> are the required properties."  That seemed like the fsl-flexcan.txt
>> file was then pointless.
> 
> There is the compatible string, and you could mention that there is a
> single reg resource and a single interrupt.
> 
>>> Removing the binding altogether seems extreme as well -- we should have
>>> bindings for all devices, even if there are no special properties.
>>
>> Ok.  I can do that too.  Who is the definitive source for that answer?
> 
> For policy questions on device tree bindings?  Grant Likely is the
> maintainer for device tree stuff.
> 
> A lot of the simpler bindings have been left undocumented so far, IMHO
> it should be a goal to document them all.  There are some existing ones
> that are documented despite not having special properties, e.g.
> Documentation/devicetree/bindings/serio/altera_ps2.txt,
> Documentation/devicetree/bindings/arm/sirf.txt,
> Documentation/devicetree/bindings/powerpc/nintendo/wii.txt, etc.
> 
>> I assume we are talking about the fsl-flexcan.txt file when we say
>> binding.  Is that correct?
> 
> Yes, although devicetree.org is another possibility.
> 
>>>> Additionally, the p1010*dts files are not
>>>> following the standard for node naming in that they have a trailing -v1.0.
>>>
>>> What "standard for node naming"?  There's nothing wrong with putting a
>>
>> For the answer to that, you will need to ask Wolfgang Grandegger.  I was
>> working from his feedback.  Looking at the plethora of other node names,
>> the vast majority do not have any -v#.#, and the ones that do also tend
>> to have multiple versions. Based upon that, I suspect he is correct,
>> but I do not know where the documentation is or if it even exists.
> 
> There's a lot of crap in old bindings, plus it's not appropriate for all
> circumstances (specifying bindings should be done a little more
> carefully than "what do most other bindings do?").  It's something we've
> been doing lately for blocks that have a version number, but it's not
> dynamically readable.
> 
> Looking in the FlexCAN chapter of the p1010 manual, I don't see any
> reference to a block version, and I do see references to "previous
> FlexCAN versions".  So I suggest "fsl,p1010-flexcan".

OK, just

  "fsl,p1010-flexcan"

or

  "fsl,p1010-flexcan", "fsl,flexcan"


Note that the Flexcan is used on Freescale ARM cores as well (and device
tree for ARM will show up soon).

Wolfgang.
