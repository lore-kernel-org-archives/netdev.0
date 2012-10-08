From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] flexcan: disable bus error interrupts for the i.MX28
Date: Mon, 08 Oct 2012 11:03:46 +0200
Message-ID: <507296F2.9010402@grandegger.com>
References: <5065A35B.3020702@grandegger.com> <20121007030858.GJ20231@S2101-09.ap.freescale.net> <50719647.4070404@grandegger.com> <7FE21149F4667147B645348EC60578850B2A361F@039-SN2MPN1-011.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Shawn Guo <shawn.guo@linaro.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux-CAN <linux-can@vger.kernel.org>,
	Hui Wang <jason77.wang@gmail.com>
To: Dong Aisheng-B29396 <B29396@freescale.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <7FE21149F4667147B645348EC60578850B2A361F@039-SN2MPN1-011.039d.mgd.msft.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dong,

On 10/08/2012 09:59 AM, Dong Aisheng-B29396 wrote:
> Hi Wolfgang,
> 
>> On 10/07/2012 05:09 AM, Shawn Guo wrote:
>>> On Fri, Sep 28, 2012 at 03:17:15PM +0200, Wolfgang Grandegger wrote:
>>>> Due to a bug in most Flexcan cores, the bus error interrupt needs to
>>>> be enabled. Otherwise we don't get any error warning or passive
>>>> interrupts. This is _not_ necessay for the i.MX28 and this patch
>>>> disables bus error interrupts if "berr-reporting" is not requested.
>>>> This avoids bus error flooding, which might harm, especially on
>>>> low-end systems.
>>>>
>>>> To handle such quirks of the Flexcan cores, a hardware feature flag
>>>> has been introduced, also replacing the "hw_ver" variable. So far
>>>> nobody could tell what Flexcan core version is available on what
>>>> Freescale SOC, apart from the i.MX6Q and P1010, and which bugs or
>>>> features are present on the various "hw_rev".
>>>>
>>>> CC: Hui Wang <jason77.wang@gmail.com>
>>>> CC: Shawn Guo <shawn.guo@linaro.org>
>>>> Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
>>>> ---
>>>>
>>>> Concerning the bug, I know that the i.MX35 does have it. Maybe other
>>>> Flexcan cores than on the i.MX28 does *not* have it either. If you
>>>> have a chance, please check on the P1010, i.MX6Q, i.MX51, i.MX53,
>>>> etc.
>>>
>>> >From what I can tell, i.MX35, i.MX51 and i.MX53 use the same version,
>>> so they should all have the bug.  And for i.MX6Q, since it uses a
>>> newer version even than i.MX28, I would believe it's affected by the bug.
>>> But I'm copying Dong who should have better knowledge about this to
>>> confirm.
>>
>> Thank for clarification. I have a i.MX6Q board but without CAN adapter :(,
>> unfortunately. Otherwise I would try it out myself.
>>
> How did you verify this issue?

I provoke state changes, e.g. by sending a message without connection to
the bus. On the Mx28, the TWRN_INT/RWRN_INT/(BOFF_INT?) does trigger the
corresponding interrupt. This does not work properly on some other
cores, e.g. the Mx35. Therefore we enable ERR_INT for those cores to
realize state changes.

> I just checked our ic guy of flexcan, it seems he also had no sense of this issue.
> 
> Below is some version info what I got:
> Mx6s use FlexCAN3, with IP version 10.00.12.00
> Mx53 use FlexCAN2 (with glitch filter), with IP version 03.00.00.00
> Mx28 use FlexCAN2 (with glitch filter), with IP version 03.00.04.00
> Mx35 use FlexCAN2 (without glitch filter) , with IP version 03.00.00.00
> Mx25 use FlexCAN2 (without glitch filter), with IP version 03.00.00.00
> I'm not sure if mx6q has such issue.

OK, we need to find that out experimentally.

Wolfgang.



