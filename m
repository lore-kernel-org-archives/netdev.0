From: Andy Gross <andy.gross-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [v5,1/5] soc: qcom: smem_state: Fix include for ERR_PTR()
Date: Thu, 1 Dec 2016 08:21:51 -0600
Message-ID: <CAPBZ5Qf8Z7-0Bvsuj88=jY8ZULU9ntCAAOqV_a0OGL4oYSTdWQ@mail.gmail.com>
References: <1479190014-11297-1-git-send-email-bjorn.andersson@linaro.org>
 <a4095c49fe5a42c4a405b1faf6c0f3b7@euamsexm01a.eu.qualcomm.com>
 <20161118183541.GI28340@tuxbot> <877f7vimyg.fsf@kamboji.qca.qualcomm.com>
 <878ts0u7z3.fsf@kamboji.qca.qualcomm.com> <874m2otenv.fsf@kamboji.qca.qualcomm.com>
 <87r35srm0c.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        "k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "wcn36xx-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <wcn36xx-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Valo, Kalle" <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87r35srm0c.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 1 December 2016 at 04:17, Valo, Kalle <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org> wrote:
> Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org> writes:
>
>> Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org> writes:
>>
>>> "Valo, Kalle" <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org> writes:
>>>
>>>> Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> writes:
>>>>
>>>>> On Wed 16 Nov 10:49 PST 2016, Kalle Valo wrote:
>>>>>
>>>>>> Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> wrote:
>>>>>> > The correct include file for getting errno constants and ERR_PTR() is
>>>>>> > linux/err.h, rather than linux/errno.h, so fix the include.
>>>>>> >
>>>>>> > Fixes: e8b123e60084 ("soc: qcom: smem_state: Add stubs for disabled smem_state")
>>>>>> > Acked-by: Andy Gross <andy.gross-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
>>>>>> > Signed-off-by: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
>>>>>>
>>>>>> For some reason this fails to compile now. Can you take a look, please?
>>>>>>
>>>>>> ERROR: "qcom_wcnss_open_channel" [drivers/net/wireless/ath/wcn36xx/wcn36xx.ko] undefined!
>>>>>> make[1]: *** [__modpost] Error 1
>>>>>> make: *** [modules] Error 2
>>>>>>
>>>>>> 5 patches set to Changes Requested.
>>>>>>
>>>>>> 9429045 [v5,1/5] soc: qcom: smem_state: Fix include for ERR_PTR()
>>>>>> 9429047 [v5,2/5] wcn36xx: Transition driver to SMD client
>>>>>
>>>>> This patch was updated with the necessary depends in Kconfig to catch
>>>>> this exact issue and when I pull in your .config (which has QCOM_SMD=n,
>>>>> QCOM_WCNSS_CTRL=n and WCN36XX=y) I can build this just fine.
>>>>>
>>>>> I've tested the various combinations and it seems to work fine. Do you
>>>>> have any other patches in your tree?
>>>>
>>>> This was with the pending branch of my ath.git tree. There are other
>>>> wireless patches (ath10k etc) but I would guess they don't affect here.
>>>>
>>>>> Any stale objects?
>>>>
>>>> Not sure what you mean with this question, but I didn't run 'make clean'
>>>> if that's what you are asking.
>>>>
>>>>> Would you mind retesting this, before I invest more time in trying to
>>>>> reproduce the issue you're seeing?
>>>>
>>>> Sure, I'll take a look but that might take few days.
>>>
>>> I didn't find enough time to look at this in detail. I applied this to
>>> my ath.git pending branch, let's see what the kbuild bot finds.
>>
>> It found the same problem. Interestingly I'm also building x86 with 32
>> bit, maybe it's related?
>>
>> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/kvalo/ath.git pending
>> head:   1ea16a1c457939b4564643f7637d5cc639a8d3b7
>> commit: 5eb09c672b01460804fd49b1c9cc7d1072a102f0 [96/99] wcn36xx: Transition driver to SMD client
>> config: i386-allmodconfig (attached as .config)
>> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
>> reproduce:
>>         git checkout 5eb09c672b01460804fd49b1c9cc7d1072a102f0
>>         # save the attached .config to linux build tree
>>         make ARCH=i386
>>
>> All errors (new ones prefixed by >>):
>>
>>>> ERROR: "qcom_wcnss_open_channel" [drivers/net/wireless/ath/wcn36xx/wcn36xx.ko] undefined!
>
> Bjorn mentioned me on IRC that this is because of a missing commit in my
> tree:
>
> daa6e41ce2b5 soc: qcom: wcnss_ctrl: Stub wcnss_ctrl API
>
> When I pull the tag below (which contains the above commit) wcn36xx
> builds fine for me:
>
> git://git.kernel.org/pub/scm/linux/kernel/git/agross/linux.git tags/qcom-drivers-for-4.10
>
> Andy, is it ok if I pull your tag also to my ath.git tree to solve the
> wcn36xx build problem? My trees go to Linus via net-next and I don't
> know when exactly Dave would send a pull request to Linus, before or
> after the arm trees, but as the tag seems to contain only few patches I
> hope it doesn't matter.

The qcom-drivers-for-4.10 tag was already merged into arm-soc.  But
having you pull it as well won't cause issues so long as you are using
the tag (which you are).  I don't see any issues with this approach.

Andy
