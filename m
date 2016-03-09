From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH v3 0/8] arm64: rockchip: Initial GeekBox enablement
Date: Wed, 9 Mar 2016 15:31:36 +0100
Message-ID: <56E033C8.40506@st.com>
References: <1457294038-14243-1-git-send-email-afaerber@suse.de>
 <56DD7172.4000707@suse.de> <2714888.1DdqvJZ8cb@diego>
 <56DD7593.5060003@suse.de> <56DD8176.2080603@st.com>
 <56DD8FBE.9010200@suse.de> <56DD99A4.5030004@st.com>
 <56DDA26C.3050301@suse.de> <56DDA3D5.3090209@st.com>
 <56DDB749.1020808@suse.de>
 <CADhT+wfO8x4En78g5ixnnwbpaeXJGDo+Q1sOABYsbXzNZy0CPw@mail.gmail.com>
 <56DE7E1D.5070508@st.com>
 <CADhT+weKf+F98uxCQhRa2RfMm8+4p=rrNZc-Vf=w_HPycXto=A@mail.gmail.com>
 <CAAObsKD9HoEbtV_JMz_R=bcrQseDmhncRAWP9k8djksL-LMQqw@mail.gmail.com>
 <56DFE55B.2090806@st.com> <56DFE64B.8060606@st.com>
 <CAAObsKBr9SXg1-wr9O-ypR8JozdGpeAwfDLMeUKi8ozxkKyTXg@mail.gmail.com>
 <56DFF253.9050208@st.com> <56DFFA9E.7060602@st.com>
 <CAAObsKBUzBXcamEyup44N1bYUzGr_ZZTsYcD5x3PXb-2E00cGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
 Dinh Nguyen <dinh.linux@gmail.com>,
 =?UTF-8?B?SGVpa28gU3TDvGJuZXI=?= <heiko@sntech.de>, netdev@vger.kernel.org,
 LKML <linux-kernel@vger.kernel.org>,
 =?UTF-8?B?RnJhbmsgU2Now6RmZXI=?= <fschaefer.oss@googlemail.com>,
 "open list:ARM/Rockchip SoC..." <linux-rockchip@lists.infradead.org>,
 Gabriel Fernandez <gabriel.fernandez@linaro.org>,
 Fabrice GASNIER <fabrice.gasnier@st.com>,
 =?UTF-8?B?QW5kcmVhcyBGw6Ry?= =?UTF-8?B?YmVy?= <afaerber@suse.de>,
 LAKML <linux-arm-kernel@lists.infradead.org>,
 Alexandre TORGUE <alexandre.torgue@st.com>
To: Tomeu Vizoso <tomeu@tomeuvizoso.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CAAObsKBUzBXcamEyup44N1bYUzGr_ZZTsYcD5x3PXb-2E00cGA@mail.gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi Tomeu

On 3/9/2016 11:53 AM, Tomeu Vizoso wrote:
> On 9 March 2016 at 11:27, Giuseppe CAVALLARO <peppe.cavallaro@st.com> wrote:
>> Hello Tomeu, Andreas,
>>
>> On 3/9/2016 10:52 AM, Giuseppe CAVALLARO wrote:
>>>>
>>>> * today's linux-next: probe failed
>>>>
>>>> * today's linux-next + revert of 88f8b1bb41c6 stmmac: Fix 'eth0: No
>>>> PHY found' regression: probe succeeded but no network at all
>>>>
>>>> * today's linux-next + revert of 88f8b1bb41c6 (stmmac: Fix 'eth0: No
>>>> PHY found' regression) + revert of 0e80bdc9a72d (stmmac: first frame
>>>> prep at the end of xmit routine): probe succeeded, dhcp succeeds and
>>>> nfsroot works for a few seconds before timing out
>>>
>>>
>>> ok, I was looking at this problem now that seems to related
>>> the "stmmac: first frame prep at the end of xmit routine"
>>> that, at first glance, is breaking the gmac 3.50 with normal descriptor.
>>
>>
>> I have no Hw where to test this use case. So, I wonder if may I ask you to
>> test some patch.
>>
>> This first patch adds a missing barrier to the normal routine that inits the
>> descriptor. Barrier was needed to well manage the OWN
>> descriptor and it was not added in case of normal desc case after
>> the xmit rework.
>>
>> Then I will check the algo behind the new xmit and in case of problems,
>> if you agree, we will decide to revert it because it aimed to add an
>> optimization.
>>
>> Let me know if you agree.
>
> I'm not sure what you would like to be tested, but just in case, I
> have just tried your patch on top of these commits and the result is
> the "transmit queue 0 timed out" error during boot:
>
> 6542b30d0a67 Revert "stmmac: first frame prep at the end of xmit routine"
> eb5274cbc0f7 Revert "stmmac: do not poll phy handler when attach a switch"
> e88e625a68d9 Revert "stmmac: fix phy init when attached to a phy"
> ef5dd3777876 stmmac: fix MDIO settings
> 77634ba1f25c Revert "stmmac: Fix 'eth0: No PHY found' regression"
> 7811b4ffc312 Add linux-next specific files for 20160309

I missed that the issue is not only related the
   "stmmac: first frame prep at the end of xmit routine"
I have to try to test on 3.50 with normal descriptor.
When using enhanced descriptors all works fine on my
side.

I keep you informed.

peppe


> Regards,
>
> Tomeu
>
>> Regards
>> Peppe
>
>
