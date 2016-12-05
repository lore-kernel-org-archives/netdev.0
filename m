From: "Valo, Kalle" <kvalo@qca.qualcomm.com>
Subject: Re: [v5,1/5] soc: qcom: smem_state: Fix include for ERR_PTR()
Date: Mon, 5 Dec 2016 11:45:45 +0000
Message-ID: <877f7eoazc.fsf@kamboji.qca.qualcomm.com>
References: <1479190014-11297-1-git-send-email-bjorn.andersson@linaro.org>
        <a4095c49fe5a42c4a405b1faf6c0f3b7@euamsexm01a.eu.qualcomm.com>
        <20161118183541.GI28340@tuxbot> <877f7vimyg.fsf@kamboji.qca.qualcomm.com>
        <878ts0u7z3.fsf@kamboji.qca.qualcomm.com>
        <874m2otenv.fsf@kamboji.qca.qualcomm.com>
        <87r35srm0c.fsf@kamboji.qca.qualcomm.com>
        <CAPBZ5Qf8Z7-0Bvsuj88=jY8ZULU9ntCAAOqV_a0OGL4oYSTdWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Bjorn Andersson <bjorn.andersson@linaro.org>,
        "k.eugene.e@gmail.com" <k.eugene.e@gmail.com>,
        "wcn36xx@lists.infradead.org" <wcn36xx@lists.infradead.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>,
        Andy Gross <andy.gross@linaro.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPBZ5Qf8Z7-0Bvsuj88=jY8ZULU9ntCAAOqV_a0OGL4oYSTdWQ@mail.gmail.com>       (Andy
 Gross's message of "Thu, 1 Dec 2016 08:21:51 -0600")
Content-Language: en-US
Content-ID: <DF8A730E94983E4C851F2F25B5D93CB3@qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Andy Gross <andy.gross@linaro.org> writes:

> On 1 December 2016 at 04:17, Valo, Kalle <kvalo@qca.qualcomm.com> wrote:
>> Kalle Valo <kvalo@qca.qualcomm.com> writes:
>>
>>> It found the same problem. Interestingly I'm also building x86 with 32
>>> bit, maybe it's related?
>>>
>>> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/kvalo/ath.git p=
ending
>>> head:   1ea16a1c457939b4564643f7637d5cc639a8d3b7
>>> commit: 5eb09c672b01460804fd49b1c9cc7d1072a102f0 [96/99] wcn36xx: Trans=
ition driver to SMD client
>>> config: i386-allmodconfig (attached as .config)
>>> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
>>> reproduce:
>>>         git checkout 5eb09c672b01460804fd49b1c9cc7d1072a102f0
>>>         # save the attached .config to linux build tree
>>>         make ARCH=3Di386
>>>
>>> All errors (new ones prefixed by >>):
>>>
>>>>> ERROR: "qcom_wcnss_open_channel" [drivers/net/wireless/ath/wcn36xx/wc=
n36xx.ko] undefined!
>>
>> Bjorn mentioned me on IRC that this is because of a missing commit in my
>> tree:
>>
>> daa6e41ce2b5 soc: qcom: wcnss_ctrl: Stub wcnss_ctrl API
>>
>> When I pull the tag below (which contains the above commit) wcn36xx
>> builds fine for me:
>>
>> git://git.kernel.org/pub/scm/linux/kernel/git/agross/linux.git tags/qcom=
-drivers-for-4.10
>>
>> Andy, is it ok if I pull your tag also to my ath.git tree to solve the
>> wcn36xx build problem? My trees go to Linus via net-next and I don't
>> know when exactly Dave would send a pull request to Linus, before or
>> after the arm trees, but as the tag seems to contain only few patches I
>> hope it doesn't matter.
>
> The qcom-drivers-for-4.10 tag was already merged into arm-soc.  But
> having you pull it as well won't cause issues so long as you are using
> the tag (which you are).  I don't see any issues with this approach.

Andy, thanks for the confirmation.

Dave, how do you suggest to handle depency issues like this? I have
pending important wcn36xx patches (converting the driver to use the
recently introduced proper SMD subsystem) which have a build dependency
on a commit which is in Andy's tag qcom-drivers-for-4.10. The commit in
question is currently in arm-soc tree going to 4.10, but not in your
net-next tree. I assume Linus will pull that during the next merge
window.

What I'm planning to do is to pull tag qcom-drivers-for-4.10 to my tree
and then send the patches to you. This will mean that from my pull
request you would get four new qcom-drivers commits which are not in
your tree, yet. Or do you prefer that I wait the qcom-drivers commits
trickle down from Linux until I send you wcn36xx patches? Or something
else?

$ git pull git://git.kernel.org/pub/scm/linux/kernel/git/agross/linux.git t=
ags/qcom-drivers-for-4.10
>From git://git.kernel.org/pub/scm/linux/kernel/git/agross/linux
 * tag                         qcom-drivers-for-4.10 -> FETCH_HEAD
Auto-merging MAINTAINERS
Merge made by the 'recursive' strategy.
 MAINTAINERS                                  |    1 +
 drivers/firmware/qcom_scm.c                  |    4 +++-
 include/dt-bindings/pinctrl/qcom,pmic-gpio.h |    4 ++++
 include/dt-bindings/pinctrl/qcom,pmic-mpp.h  |    6 ++++++
 include/linux/soc/qcom/wcnss_ctrl.h          |   13 +++++++++++++
 5 files changed, 27 insertions(+), 1 deletion(-)

$ git log --oneline ORIG_HEAD..
6d0491261ecc Merge tag 'qcom-drivers-for-4.10' of git://git.kernel.org/pub/=
scm/linux/kernel/git/agross/linux into test
bd4760ca0315 firmware: qcom: scm: Use devm_reset_controller_register()
4fb1a4207804 MAINTAINERS: add drivers/pinctrl/qcom to ARM/QUALCOMM SUPPORT
636959fc1232 pinctrl: pm8994: add pad voltage regulator defines
daa6e41ce2b5 soc: qcom: wcnss_ctrl: Stub wcnss_ctrl API
$

--=20
Kalle Valo=
