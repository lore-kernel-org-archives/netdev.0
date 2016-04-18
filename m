From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH v5 2/4] Documentation: Bindings: Add STM32 DWMAC glue
Date: Mon, 18 Apr 2016 16:34:35 +0200
Message-ID: <5714F07B.3010005@st.com>
References: <1458315428-10081-1-git-send-email-alexandre.torgue@gmail.com>	<1458315428-10081-3-git-send-email-alexandre.torgue@gmail.com>	<CAGb2v65SvVi0cJbaaD9cYrqC3pJ9eumwhTVk11_N7r_nTZhS9g@mail.gmail.com>	<20160321124043.GA26873@rob-hp-laptop>	<CAGhQ9VwS=YwgfeUuK+LzGjy3f9btVGV7bN=TATGHwQs+JW+iGA@mail.gmail.com> <CAJgp7zxfFRhfNjcE23n+DKD0ffrvH4_sowPjK_-DZAS4ecH5dg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <robh@kernel.org>, Chen-Yu Tsai <wens@csie.org>,
	Maxime Coquelin <mcoquelin.stm32@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	devicetree <devicetree@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
To: Alexandre Torgue <alexandre.torgue@gmail.com>,
	Joachim Eastwood <manabian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:45662 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751989AbcDROfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 10:35:11 -0400
In-Reply-To: <CAJgp7zxfFRhfNjcE23n+DKD0ffrvH4_sowPjK_-DZAS4ecH5dg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/22/2016 5:11 PM, Alexandre Torgue wrote:
> Hi guys,
>
> I will fix typo issues (s/vesrion/version and ethernet @).
>
> Concerning compatible string. For sure "snps,dwmac-3.50a" string is
> not used inside glue driver.
> I perfere to keep it for information but if you really want that I
> remove it I will not block ;)
>
> 2016-03-21 16:36 GMT+01:00 Joachim  Eastwood <manabian@gmail.com>:
>> On 21 March 2016 at 13:40, Rob Herring <robh@kernel.org> wrote:
>>> On Sat, Mar 19, 2016 at 12:00:22AM +0800, Chen-Yu Tsai wrote:
>>>> Hi,
>>>>
>>>> On Fri, Mar 18, 2016 at 11:37 PM, Alexandre TORGUE
>>>> <alexandre.torgue@gmail.com> wrote:
>>>>> +- clocks: Must contain a phandle for each entry in clock-names.
>>>>> +- clock-names: Should be "stmmaceth" for the host clock.
>>>
> We can remove host clock (stmmac eth) entry here and refer to
> stmmac.txt binding for common entry
>
>>> This doesn't sound like the clock input signal name...
>>>
>>>>> +              Should be "tx-clk" for the MAC TX clock.
>>>>> +              Should be "rx-clk" for the MAC RX clock.
>>>
>>> How can other DWMAC blocks not have these clocks? The glue can't really
>>> add these clocks. It could combine them into one or a new version of
>>> DWMAC could have a different number of clock inputs. So if there is
>>> variation here, then some of the bindings are probably wrong. I guess
>>> the only change I'm suggesting is possibly moving these into common
>>> binding doc.
>>
>> The LPC18xx implementation probably have these clocks as well but the
>> LPC1850 user manual only documents the main clock. Someone with access
>> to the IP block doc from Synopsys should be able to check which clocks
>> the MAC really needs.
>>
>> Rockchip bindings have two clocks named "mac_clk_rx" and "mac_clk_tx".
>> These are probably the same as stm32 needs so maybe use these names
>> and move them into the main doc and update the rockchip binding.
>>
> I think we can use same name. But I have a doubt on moving it in a
> common bindings (maybe I don't well understood). When you say "common
> binding file" is it "stmmac.txt" binding ? If yes does it mean that we
> have to control it inside stmmac driver (no more in glue) ? In this
> case those clocks will become "required" for stm32 and rockship but
> not for others chip. It could create confusion?

Currently we keep the "host" and "csr" " ptp  "clock from common
bindings because directly connected to the either MAC core or optional
internals modules.
Indeed, also clk_tx_i and clk_rx_i could be treated in the same way.
but... (my personal view).
Many platforms, also inside STi, have different clock routing schema,
so we could relax them giving each glue the way to internally manage
all (as done nowadays).
So these clocks can stay inside the glue and documented inside each
binding doc. Maybe, it could be not so easy to have generic schema
suitable for all the glues so documenting all inside the same binding
text file.
We could try to better name these clocks in each glue. For example, for
this, although I do not know the clk schema, I can image a single
rmii_clk (maybe from internal oscillator) that is connected to
clk_tx_i and clk_rx_i. So it could be useless to pass both. Please
let me know if I am wrong...
In case of (G)MII, we should use something like (g)mii_tx_clk,
(g)mii_rx_clk according to the real connections (if from
an internal oscillator and not from an ext one connected to the phy).

Regards,
Peppe


> Best regards
>
> Alex
>
>>
>> regards,
>> Joachim Eastwood
>
