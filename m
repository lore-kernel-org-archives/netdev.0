From: Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Subject: Re: [PATCH v3 0/8] arm64: rockchip: Initial GeekBox enablement
Date: Wed, 9 Mar 2016 15:53:02 +0100
Message-ID: <56E038CE.606@st.com>
References: <1457294038-14243-1-git-send-email-afaerber@suse.de> <56DD7172.4000707@suse.de> <2714888.1DdqvJZ8cb@diego> <56DD7593.5060003@suse.de> <56DD8176.2080603@st.com> <56DD8FBE.9010200@suse.de> <56DD99A4.5030004@st.com> <56DDA26C.3050301@suse.de> <56DDA3D5.3090209@st.com> <56DDB749.1020808@suse.de> <CADhT+wfO8x4En78g5ixnnwbpaeXJGDo+Q1sOABYsbXzNZy0CPw@mail.gmail.com> <56DE7E1D.5070508@st.com> <CADhT+weKf+F98uxCQhRa2RfMm8+4p=rrNZc-Vf=w_HPycXto=A@mail.gmail.com> <CAAObsKD9HoEbtV_JMz_R=bcrQseDmhncRAWP9k8djksL-LMQqw@mail.gmail.com> <56DFE55B.2090806@st.com> <56DFE64B.8060606@st.com> <CAAObsKBr9SXg1-wr9O-ypR8JozdGpeAwfDLMeUKi8ozxkKyTXg@mail.gmail.com> <56DFF253.9050208@st.com> <56DFFA9E.7060602@st.com> <CAAObsKBUzBXcamEyup44N1bYUzGr_ZZTsYcD5x3PXb-2E00cGA@mail.gmail.com> <56E033C8.40506@st.c
 om>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Fabrice GASNIER <fabrice.gasnier-qxv4g6HH51o@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	=?UTF-8?B?SGVpa28gU3TDvGJuZXI=?= <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"open list:ARM/Rockchip SoC..." <linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	LAKML <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Gabriel Fernandez <gabriel.fernandez-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
	=?UTF-8?B?RnJhbmsgU2Now6RmZXI=?= <fschaefer.oss-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Tomeu Vizoso <tomeu-XCtybt49RKsYaV1qd6yewg@public.gmane.org>,
	Dinh Nguyen <dinh.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	=?UTF-8?B?QW5kcmVhcyBGw6RyYmVy?= <afaerber-l3A5Bk7waGM@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <56E033C8.40506-qxv4g6HH51o@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Tomeu, Dinh, Andreas

I need a sum and help from you to go ahead on the
tx timeout.

The "stmmac: MDIO fixes" seems to be the candidate to
fix the phy connection and I will send the V2 asap (Andreas' comment).

So, supposing the probe is ok and phy is connected,
I need your input ...

  Tomeu: after revering the 0e80bdc9a72d (stmmac: first frame
         prep at the end of xmit routine) the network is
         not stable and there is a timeout after a while.
         The box has 3.50 with normal desc settings.

  Dinh: the network is ok, I wonder if you can share a boot
        log just to understand if the normal or enhanced
        descriptors are used.

  Andreas: you are also using 3.50 with normal desc but I have not
           clear if just reverting 0e80bdc9a72d  commit the
           network is ok or you see timeout issues.

In the meantime I am trying to find a box where try normal setup
and I can confirm that enhanced descriptors are ok on my side

Regards
Peppe




On 3/9/2016 3:31 PM, Giuseppe CAVALLARO wrote:
> Hi Tomeu
>
> On 3/9/2016 11:53 AM, Tomeu Vizoso wrote:
>> On 9 March 2016 at 11:27, Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
>> wrote:
>>> Hello Tomeu, Andreas,
>>>
>>> On 3/9/2016 10:52 AM, Giuseppe CAVALLARO wrote:
>>>>>
>>>>> * today's linux-next: probe failed
>>>>>
>>>>> * today's linux-next + revert of 88f8b1bb41c6 stmmac: Fix 'eth0: No
>>>>> PHY found' regression: probe succeeded but no network at all
>>>>>
>>>>> * today's linux-next + revert of 88f8b1bb41c6 (stmmac: Fix 'eth0: No
>>>>> PHY found' regression) + revert of 0e80bdc9a72d (stmmac: first frame
>>>>> prep at the end of xmit routine): probe succeeded, dhcp succeeds and
>>>>> nfsroot works for a few seconds before timing out
>>>>
>>>>
>>>> ok, I was looking at this problem now that seems to related
>>>> the "stmmac: first frame prep at the end of xmit routine"
>>>> that, at first glance, is breaking the gmac 3.50 with normal
>>>> descriptor.
>>>
>>>
>>> I have no Hw where to test this use case. So, I wonder if may I ask
>>> you to
>>> test some patch.
>>>
>>> This first patch adds a missing barrier to the normal routine that
>>> inits the
>>> descriptor. Barrier was needed to well manage the OWN
>>> descriptor and it was not added in case of normal desc case after
>>> the xmit rework.
>>>
>>> Then I will check the algo behind the new xmit and in case of problems,
>>> if you agree, we will decide to revert it because it aimed to add an
>>> optimization.
>>>
>>> Let me know if you agree.
>>
>> I'm not sure what you would like to be tested, but just in case, I
>> have just tried your patch on top of these commits and the result is
>> the "transmit queue 0 timed out" error during boot:
>>
>> 6542b30d0a67 Revert "stmmac: first frame prep at the end of xmit routine"
>> eb5274cbc0f7 Revert "stmmac: do not poll phy handler when attach a
>> switch"
>> e88e625a68d9 Revert "stmmac: fix phy init when attached to a phy"
>> ef5dd3777876 stmmac: fix MDIO settings
>> 77634ba1f25c Revert "stmmac: Fix 'eth0: No PHY found' regression"
>> 7811b4ffc312 Add linux-next specific files for 20160309
>
> I missed that the issue is not only related the
>    "stmmac: first frame prep at the end of xmit routine"
> I have to try to test on 3.50 with normal descriptor.
> When using enhanced descriptors all works fine on my
> side.
>
> I keep you informed.
>
> peppe
>
>
>> Regards,
>>
>> Tomeu
>>
>>> Regards
>>> Peppe
>>
>>
>
>
>

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
