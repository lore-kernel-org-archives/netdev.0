From: Hein Tibosch <hein_tibosch@yahoo.es>
Subject: Re: [PATCH] net/macb: fix ISR clear-on-write behavior only for some
 SoC
Date: Tue, 14 May 2013 15:18:19 +0800
Message-ID: <5191E53B.9000106@yahoo.es>
References: <1368461105-23128-1-git-send-email-nicolas.ferre@atmel.com> <FE065E51-1EAA-47ED-8C7B-0F2E6418F349@jcrosoft.com> <51918C23.7040106@yahoo.es> <20130514055256.GD22508@game.jcrosoft.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: michal.simek@xilinx.com,
	Ludovic Desroches <ludovic.desroches@atmel.com>,
	s.trumtrar@pengutronix.de, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130514055256.GD22508@game.jcrosoft.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 5/14/2013 1:52 PM, Jean-Christophe PLAGNIOL-VILLARD wrote:
> On 08:58 Tue 14 May     , Hein Tibosch wrote:
>> On 5/14/2013 12:05 AM, Jean-Christophe PLAGNIOL-VILLARD wrote:
>>> On May 14, 2013, at 12:05 AM, Nicolas Ferre <nicolas.ferre@atmel.com> wrote:
>>>
>>>> Commit 749a2b6 (net/macb: clear tx/rx completion flags in ISR)
>>>> introduces clear-on-write on ISR register. This behavior is not always
>>>> implemented when using Cadence MACB/GEM and is breaking other platforms.
>>>> We are using a new Device Tree compatibility string and a capability
>>>> property to actually activate this clear-on-write behavior on ISR.
>>>>
>>>> Reported-by: Hein Tibosch <hein_tibosch@yahoo.es>
>>>> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
>>> can we detect it via the IP?
>> This was my first proposal, have it based on the value of MACB's
>> register 'MID' (offset 0x00fc, lower 16 bits).
>> On avr32 it reads: 0x0000010D, on Zynq it reports 0x00000119
>>
>> So for the moment, CAPS_ISR_CLEAR_ON_WRITE could be set if the revision
>> equals to 0x00000119?
> so no it will not work
>
> as the gem on sama5 is 00020119
>
> so version 0x119 too
>
> nico

All right, that's a pity.

The only issue that remains then is the obligation to use CONFIG_OF,
or:

+#if defined(CONFIG_OF)
+	dev_id = of_match_device(macb_dt_ids, &pdev->dev);
+	if (dev_id)
+		bp->caps = (u32)dev_id->data;
+
+#endif

?

Hein
