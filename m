From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH V5 1/2] firmware: add more flexible request_firmware_async function
Date: Thu, 03 Aug 2017 08:23:00 +0300
Message-ID: <878tj1ql6z.fsf@kamboji.qca.qualcomm.com>
References: <20170731150945.8925-1-zajec5@gmail.com>
        <20170802213010.GM18884@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: =?utf-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5@gmail.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Bjorn Andersson <bjorn.andersson@linaro.org>,
        Daniel Wagner <wagi@monom.org>,
        David Woodhouse <dwmw2@infradead.org>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        "Rafael J . Wysocki" <rjw@rjwysocki.net>, yi1.li@linux.intel.com,
        atull@kernel.org, Moritz Fischer <moritz.fischer@ettus.com>,
        pmladek@suse.com, Johannes Berg <johannes.berg@intel.com>,
        emmanuel.grumbach@intel.com, luciano.coelho@intel.com,
        luto@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>,
        Kees Cook <keescook@chromium.org>,
        AKASHI Takahiro <takahiro.akashi@linaro.org>,
        David Howells <dhowells@redhat.com>, pjones@redhat.com,
        Hans de Goede <hdegoede@redhat.com>, alan@linux.intel.com,
        tyt
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170802213010.GM18884@wotan.suse.de> (Luis R. Rodriguez's
        message of "Wed, 2 Aug 2017 23:30:10 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Luis R. Rodriguez" <mcgrof@kernel.org> writes:

>> +int request_firmware_nowait(struct module *module, bool uevent,
>> +			    const char *name, struct device *device, gfp_t gfp,
>> +			    void *context,
>> +			    void (*cont)(const struct firmware *fw, void *context))
>> +{
>> +	unsigned int opt_flags = FW_OPT_FALLBACK |
>> +		(uevent ? FW_OPT_UEVENT : FW_OPT_USERHELPER);
>> +
>> +	return __request_firmware_nowait(module, opt_flags, name, device, gfp,
>> +					 context, cont);
>> +}
>>  EXPORT_SYMBOL(request_firmware_nowait);
>>  
>> +int __request_firmware_async(struct module *module, const char *name,
>> +			     struct firmware_opts *fw_opts, struct device *dev,
>> +			     void *context,
>> +			     void (*cont)(const struct firmware *fw, void *context))
>> +{
>> +	unsigned int opt_flags = FW_OPT_UEVENT;
>
> This exposes a long issue. Think -- why do we want this enabled by default? Its
> actually because even though the fallback stuff is optional and can be, the uevent
> internal flag *also* provides caching support as a side consequence only. We
> don't want to add a new API without first cleaning up that mess.
>
> This is a slipery slope and best to clean that up before adding any new API.
>
> That and also Greg recently stated he would like to see at least 3 users of
> a feature before adding it. Although I think that's pretty arbitrary, and
> considering that request_firmware_into_buf() only has *one* user -- its what
> he wishes.

ath10k at least needs a way to silence the warning for missing firmware
and I think iwlwifi also.

-- 
Kalle Valo
