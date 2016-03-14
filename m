From: Tomeu Vizoso <tomeu@tomeuvizoso.net>
Subject: Re: [PATCH v3 0/8] arm64: rockchip: Initial GeekBox enablement
Date: Mon, 14 Mar 2016 12:43:46 +0100
Message-ID: <CAAObsKB-tSCu5KMYk2Zi-oX9zMKEOwwT93sMkiZKiYvtexmHaQ@mail.gmail.com>
References: <1457294038-14243-1-git-send-email-afaerber@suse.de>
 <56DD7172.4000707@suse.de> <2714888.1DdqvJZ8cb@diego> <56DD7593.5060003@suse.de>
 <56DD8176.2080603@st.com> <56DD8FBE.9010200@suse.de> <56DD99A4.5030004@st.com>
 <56DDA26C.3050301@suse.de> <56DDA3D5.3090209@st.com> <56DDB749.1020808@suse.de>
 <CADhT+wfO8x4En78g5ixnnwbpaeXJGDo+Q1sOABYsbXzNZy0CPw@mail.gmail.com>
 <56DE7E1D.5070508@st.com> <CADhT+weKf+F98uxCQhRa2RfMm8+4p=rrNZc-Vf=w_HPycXto=A@mail.gmail.com>
 <CAAObsKD9HoEbtV_JMz_R=bcrQseDmhncRAWP9k8djksL-LMQqw@mail.gmail.com>
 <56DFE55B.2090806@st.com> <56DFE64B.8060606@st.com> <CAAObsKBr9SXg1-wr9O-ypR8JozdGpeAwfDLMeUKi8ozxkKyTXg@mail.gmail.com>
 <56DFF253.9050208@st.com> <56DFFA9E.7060602@st.com> <CAAObsKBUzBXcamEyup44N1bYUzGr_ZZTsYcD5x3PXb-2E00cGA@mail.gmail.com>
 <56E033C8.40506@st.com> <56E038CE.606@st.com> <CADhT+wcMpzA_Coj8Z5OQZsc3bF3a7yOmsbazQMPtcdUWkJSuCA@mail.gmail.com>
 <56E13AAB.2080900@st.com> <CADhT+wd=vcph2y_OxkGNO5EwHvN=kBy-BrfZHmNjZHww4LxmTg@mail.gmail.com>
 <56E28B5D.6000708@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dinh Nguyen <dinh.linux@gmail.com>,
	=?UTF-8?Q?Andreas_F=C3=A4rber?= <afaerber@suse.de>,
	Fabrice GASNIER <fabrice.gasnier@st.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	=?UTF-8?Q?Heiko_St=C3=BCbner?= <heiko@sntech.de>,
	netdev@vger.kernel.org,
	"open list:ARM/Rockchip SoC..." <linux-rockchip@lists.infradead.org>,
	LAKML <linux-arm-kernel@lists.infradead.org>,
	Gabriel Fernandez <gabriel.fernandez@linaro.org>,
	Alexandre TORGUE <alexandre.torgue@st.com>,
	=?UTF-8?Q?Frank_Sch=C3=A4fer?= <fschaefer.oss@googlemail.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56E28B5D.6000708@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11 March 2016 at 10:09, Giuseppe CAVALLARO <peppe.cavallaro@st.com> wrote:
> On 3/10/2016 5:47 PM, Dinh Nguyen wrote:
>>
>> On Thu, Mar 10, 2016 at 3:13 AM, Giuseppe CAVALLARO
>> <peppe.cavallaro@st.com> wrote:
>>>
>>> On 3/9/2016 5:31 PM, Dinh Nguyen wrote:
>>>>
>>>>
>>>> On Wed, Mar 9, 2016 at 8:53 AM, Giuseppe CAVALLARO
>>>> <peppe.cavallaro@st.com> wrote:
>>>>>
>>>>>
>>>>> Hi Tomeu, Dinh, Andreas
>>>>>
>>>>> I need a sum and help from you to go ahead on the
>>>>> tx timeout.
>>>>>
>>>>> The "stmmac: MDIO fixes" seems to be the candidate to
>>>>> fix the phy connection and I will send the V2 asap (Andreas' comment).
>>>>>
>>>>> So, supposing the probe is ok and phy is connected,
>>>>> I need your input ...
>>>>>
>>>>>    Tomeu: after revering the 0e80bdc9a72d (stmmac: first frame
>>>>>           prep at the end of xmit routine) the network is
>>>>>           not stable and there is a timeout after a while.
>>>>>           The box has 3.50 with normal desc settings.
>>>>>
>>>>>    Dinh: the network is ok, I wonder if you can share a boot
>>>>>          log just to understand if the normal or enhanced
>>>>>          descriptors are used.
>>>>>
>>>>
>>>> Here it is:
>>>
>>>
>>> ...
>>>>
>>>>
>>>> [    0.850523] stmmac - user ID: 0x10, Synopsys ID: 0x37
>>>> [    0.855570]  Ring mode enabled
>>>> [    0.858611]  DMA HW capability register supported
>>>> [    0.863128]  Enhanced/Alternate descriptors
>>>> [    0.867482]  Enabled extended descriptors
>>>> [    0.871482]  RX Checksum Offload Engine supported (type 2)
>>>> [    0.876948]  TX Checksum insertion supported
>>>> [    0.881204]  Enable RX Mitigation via HW Watchdog Timer
>>>> [    0.886863] socfpga-dwmac ff702000.ethernet eth0: No MDIO subnode
>>>> found
>>>> [    0.899090] libphy: stmmac: probed
>>>> [    0.902484] eth0: PHY ID 00221611 at 4 IRQ POLL (stmmac-0:04) active
>>>
>>>
>>>
>>> Thx Dinh, so you are using the Enhanced/Alternate descriptors
>>> I am debugging on my side on a setup with normal descriptors, I let you
>>> know
>>>
>>
>> Doesn't the printout "Enhanced/Alternate descriptors"  mean that I'm using
>> Enhanced/Alternate descriptors?
>
>
> yes this means that you have the Databook 3.70a and, from the HW
> capability register, the driver will use the Enhanced/Alternate
> descriptors. This is the same HW I am using on my side where the
> stmmac is working fine.
>
> In the case where it is failing on net-next, although on Databook 3.50a,
> the HW  capability register says that there is no enhanced descriptors
> and the driver uses the normal ones.
>
> Tomeu, I kindly ask you to try the patch attached. I found a bug on Tx
> path for normal descriptors. Please let me know if this help.
> Also let me know if we actually need to revert the 0e80bdc9a72d.

Hi Peppe,

with that patch I don't see any difference at all in my setup.

So to be clear, with these commits on top of next-20160314, I still
get the hang during boot:

209afef6f0cd ARM: dts: rockchip: Add mdio node to ethernet node
2315acc6cf7f Revert "stmmac: first frame prep at the end of xmit routine"
b5e08e810c63 stmmac: fix tx prepare for normal desc
37c15a31d850 i2c: immediately mark ourselves as registered
4342eec3c5a2 Add linux-next specific files for 20160314

[   27.521026] WARNING: CPU: 1 PID: 0 at net/sched/sch_generic.c:303
dev_watchdog+0x284/0x288
[   27.529460] NETDEV WATCHDOG: eth0 (rk_gmac-dwmac): transmit queue 0 timed out

https://git.collabora.com/cgit/user/tomeu/linux.git/log/?h=broken-eth-on-rock2

> I am trying to find some HW where test the normal descriptors to
> speed-up the tests on my side directly.

Maybe get your tree in kernelci.org? I'm not sure if it's currently
doing any nfsroot boots, though.

Regards,

Tomeu

> Let me know and thx in advance.
>
> Regards,
> Peppe
>
>>
>> Dinh
>>
>
