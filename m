From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [PATCH V5 1/2] firmware: add more flexible
 request_firmware_async function
Date: Thu, 3 Aug 2017 18:31:02 +0200
Message-ID: <20170803163102.GA27873@wotan.suse.de>
References: <20170731150945.8925-1-zajec5@gmail.com>
 <20170802213010.GM18884@wotan.suse.de>
 <878tj1ql6z.fsf@kamboji.qca.qualcomm.com>
 <1501739717.15969.26.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "kvalo@codeaurora.org" <kvalo@codeaurora.org>,
        "mcgrof@kernel.org" <mcgrof@kernel.org>,
        "pieter-paul.giesberts@broadcom.com"
        <pieter-paul.giesberts@broadcom.com>,
        "bjorn.andersson@linaro.org" <bjorn.andersson@linaro.org>,
        "arend.vanspriel@broadcom.com" <arend.vanspriel@broadcom.com>,
        "hante.meuleman@broadcom.com" <hante.meuleman@broadcom.com>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "keescook@chromium.org" <keescook@chromium.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "alan@linux.intel.com" <alan@linux.intel.com>,
        "moritz.fischer@ettus.com" <moritz.fischer@ettus.com>,
        "pjones@redhat.com" <pjones@redhat.com>,
        "wagi@monom.org" <wagi@monom.org>,
        "pmladek@suse.com" <pmladek@suse.com>,
        "atull@kernel.org" <atull@kernel.org>
To: "Coelho, Luciano" <luciano.coelho@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1501739717.15969.26.camel@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 03, 2017 at 05:55:18AM +0000, Coelho, Luciano wrote:
> On Thu, 2017-08-03 at 08:23 +0300, Kalle Valo wrote:
> > "Luis R. Rodriguez" <mcgrof@kernel.org> writes:
> > 
> > > > +int request_firmware_nowait(struct module *module, bool uevent,
> > > > +			    const char *name, struct device *device, gfp_t gfp,
> > > > +			    void *context,
> > > > +			    void (*cont)(const struct firmware *fw, void *context))
> > > > +{
> > > > +	unsigned int opt_flags = FW_OPT_FALLBACK |
> > > > +		(uevent ? FW_OPT_UEVENT : FW_OPT_USERHELPER);
> > > > +
> > > > +	return __request_firmware_nowait(module, opt_flags, name, device, gfp,
> > > > +					 context, cont);
> > > > +}
> > > >  EXPORT_SYMBOL(request_firmware_nowait);
> > > >  
> > > > +int __request_firmware_async(struct module *module, const char *name,
> > > > +			     struct firmware_opts *fw_opts, struct device *dev,
> > > > +			     void *context,
> > > > +			     void (*cont)(const struct firmware *fw, void *context))
> > > > +{
> > > > +	unsigned int opt_flags = FW_OPT_UEVENT;
> > > 
> > > This exposes a long issue. Think -- why do we want this enabled by default? Its
> > > actually because even though the fallback stuff is optional and can be, the uevent
> > > internal flag *also* provides caching support as a side consequence only. We
> > > don't want to add a new API without first cleaning up that mess.
> > > 
> > > This is a slipery slope and best to clean that up before adding any new API.
> > > 
> > > That and also Greg recently stated he would like to see at least 3 users of
> > > a feature before adding it. Although I think that's pretty arbitrary, and
> > > considering that request_firmware_into_buf() only has *one* user -- its what
> > > he wishes.
> > 
> > ath10k at least needs a way to silence the warning for missing firmware
> > and I think iwlwifi also.
> 
> Yes, iwlwifi needs to silence the warning.  It the feature (only one,
> really) that I've been waiting for.

Perfect, can you guys send patches on top of these changes? Even though I still
think the flag stuff needs to be worked out I can try to iron that out myself
and fold the rest of the delta, and then I can set a new set out which is much
more suitable.

  Luis
