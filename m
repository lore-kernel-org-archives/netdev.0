From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH v3 1/2] wcn36xx: Transition driver to SMD client
Date: Fri, 02 Sep 2016 21:23:01 +0300
Message-ID: <87a8fqyxdm.fsf@kamboji.qca.qualcomm.com>
References: <1472741468-24762-1-git-send-email-bjorn.andersson@linaro.org>
        <87mvjqz2ul.fsf@kamboji.qca.qualcomm.com>
        <20160902164623.GY15161@tuxbot>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eugene Krasnikov <k.eugene.e@gmail.com>,
        wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-msm@vger.kernel.org
To: Bjorn Andersson <bjorn.andersson@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160902164623.GY15161@tuxbot> (Bjorn Andersson's message of
        "Fri, 2 Sep 2016 09:46:23 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bjorn Andersson <bjorn.andersson@linaro.org> writes:

> On Fri 02 Sep 09:24 PDT 2016, Kalle Valo wrote:
>
>> Bjorn Andersson <bjorn.andersson@linaro.org> writes:
>> 
>> > --- a/drivers/net/wireless/ath/wcn36xx/Kconfig
>> > +++ b/drivers/net/wireless/ath/wcn36xx/Kconfig
>> > @@ -1,6 +1,6 @@
>> >  config WCN36XX
>> >  	tristate "Qualcomm Atheros WCN3660/3680 support"
>> > -	depends on MAC80211 && HAS_DMA
>> > +	depends on MAC80211 && HAS_DMA && QCOM_SMD
>> 
>> While I had this patch on my pending branch I noticed that I can't
>> compile wcn36xx on x86 anymore. This is actually quite inconvenient, for
>> example then it's easy to miss mac80211 API changes etc. Is there any
>> way we could continue build testing wcn36xx on x86 (or all) platforms?
>> 
>
> Sorry about that, we should at least be able to COMPILE_TEST it in
> non-qcom builds. Thanks for letting me know.

Yeah, that would be better. Even though it's a bit shame that
COMPILE_TEST disables DEBUG_INFO (I use the same build also for
development) so I need to toggle it on and off whenever I need debug
symbols. Oh well...

> And the driver should also depend on QCOM_WCNSS_CTRL, in the normal
> case.
>
> I'll respin this, unless you prefer an incremental patch for those
> changes(?)

Yes, please respin.

>> Also what about older platforms? Earlier I used wcn36xx on my Nexus 4
>> with help of backports project. I can't do that anymore, right?
>> 
>
> This has been tested on 8064, 8974 and 8916. So your Nexus 4 is covered.
>
> Unfortunately I don't have a Nexus 4, but we currently have Nexus 7
> (the 8064 version), Xperia Z, Xperia Z1 and DB410c using this chip and
> all four has been tested with this code.

Actually I meant running wcn36xx on older kernels, where your QCOM_SMD
is not yet supported.

> I've staged the PIL/remoteproc (firmware "loader") driver for v4.9, so
> with this patch the only thing missing to fill in the dts files is one
> clock from the RPM.

Nice.

> JFYI, There seems to be some race in the removal path, which I will look
> into. But I would prefer if we could merge this to make the driver
> usable, and more accessible to work on.

Sure, a race like that isn't that big of a deal compared to the benefits
your work brings. But it's good to document knows regressions to the
commit log anyway so that others can be prepared if they test it.

-- 
Kalle Valo
