From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 1/1] net/macb: add DT support
Date: Fri, 02 Dec 2011 16:30:36 +0100
Message-ID: <4ED8EF1C.80503@atmel.com>
References: <1321626565-11261-1-git-send-email-plagnioj@jcrosoft.com> <20111118155824.GA9981@totoro> <20111120164740.GC21480@game.jcrosoft.org> <20111120171123.GA7845@gallagher>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	devicetree-discuss@ozlabs.org, netdev@vger.kernel.org
To: Jamie Iles <jamie@jamieiles.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from newsmtp5.atmel.com ([204.2.163.5]:11397 "EHLO
	sjogate2.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754065Ab1LBPau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 10:30:50 -0500
In-Reply-To: <20111120171123.GA7845@gallagher>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/20/2011 06:11 PM, Jamie Iles :
> On Sun, Nov 20, 2011 at 05:47:40PM +0100, Jean-Christophe PLAGNIOL-VILLARD wrote:
>> On 15:58 Fri 18 Nov     , Jamie Iles wrote:
>>> Hi Jean-Christophe,
>>>
>>> On Fri, Nov 18, 2011 at 03:29:25PM +0100, Jean-Christophe PLAGNIOL-VILLARD wrote:
>>>> allow the DT to pass the mac address and the phy mode
>>>>
>>>> Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD<plagnioj@jcrosoft.com>
>>>> Cc: Jamie Iles<jamie@jamieiles.com>
>>>> Cc: Nicolas Ferre<nicolas.ferre@atmel.com>
>>>
>>> This looks OK to me in principle.  I can't easily test this at the
>>> moment, but as I don't have a DT platform that has the clk framework up
>>> and running.  A couple of nits/questions inline, but thanks for doing
>>> this!
>>>
>>> Jamie
>>>
>>>> ---
>>>>   Documentation/devicetree/bindings/net/macb.txt |   22 ++++++++
>>>>   drivers/net/ethernet/cadence/macb.c            |   65 +++++++++++++++++++++---
>>>>   drivers/net/ethernet/cadence/macb.h            |    2 +
>>>>   3 files changed, 81 insertions(+), 8 deletions(-)
>>>>   create mode 100644 Documentation/devicetree/bindings/net/macb.txt
>>>>
>>>> diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
>>>> new file mode 100644
>>>> index 0000000..2b727ec
>>>> --- /dev/null
>>>> +++ b/Documentation/devicetree/bindings/net/macb.txt
>>>> @@ -0,0 +1,22 @@
>>>> +* Cadence EMACB
>>>> +
>>>> +Implemeted on Atmel AT91&  AVR32 SoC
>>>
>>> I think something along the lines of "Binding for the Cadence MACB
>>> Ethernet controller" rather than listing specific parts might be
>>> clearer.
>> I prefer as we will have implementation detail in the binding
>
> I can't see any Atmel specific implementation detail here though so lets
> keep it generic for now.  There isn't a benefit to keeping a list of
> SoC's that the device is implemented in here as it'll only become out of
> date.  We need to make it easy for other vendors to reuse the binding +
> driver.
>
>>>> +		compatible = "atmel,macb";
>>>
>>> This should be "cdns,macb" as it isn't Atmel specific.  I believe cdns
>>> is the correct stock ticker symbol for Cadence.
>> here I put "atmel,macb" on purpose to specify the difference of the IP between
>> the soc, in fact it should have been atmel-at91,macb
>
> Well if we really can't detect the difference from the revision register
> then we should have "cdns,macb" *and* "atmel,at91-macb" at least then
> where platforms could claim compatibility as:
>
> 	compatible = "atmel,at91-macb", "cdns,macb";

re-thinking about this I propose that we go for the following compatible 
string for macb:

- compatible: Should be "cdns,<chip>-macb"

And as the first SoC that have embedded an emacb that is compatible with 
current 10/100 AT91 usage is AVR32 at32ap7000... We may end up with 
"cdns,at32ap7000-macb" compatible string. The first ones with different 
synthesis parameters where at91sam9260/3 so I may also add:
"cdns,at91sam9260-macb".
Then you will have to add the first SoC that uses the gigabit version of 
the macb...
What do you think about that?

BTW, "cdns" seems not included in the vendor-prefixes.txt file yet...

Bye,
-- 
Nicolas Ferre
