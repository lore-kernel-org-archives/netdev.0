From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH RESEND] iwlwifi, Do not implement thermal zone unless
 ucode is loaded
Date: Thu, 14 Jul 2016 11:24:09 +0200
Message-ID: <20160714092408.GA27271@redhat.com>
References: <1468250301-10357-1-git-send-email-prarit@redhat.com>
 <CANUX_P0AFoM5VEDWDjtvOhNbExu4T1bLWU+uS-EYqoGtu5h2bw@mail.gmail.com>
 <5783E33E.7090205@redhat.com>
 <1468261650.20877.14.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "prarit@redhat.com" <prarit@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linuxwifi <linuxwifi@intel.com>,
	"Coelho, Luciano" <luciano.coelho@intel.com>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"kvalo@codeaurora.org" <kvalo@codeaurora.org>,
	"Ivgi, Chaya Rachel" <chaya.rachel.ivgi@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Sharon, Sara" <sara.sharon@intel.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54403 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751305AbcGNJ0r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2016 05:26:47 -0400
Content-Disposition: inline
In-Reply-To: <1468261650.20877.14.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 11, 2016 at 06:27:30PM +0000, Grumbach, Emmanuel wrote:
> I guess that works, but it seems wrong to me. Usually, registration
> should happen only upon INIT, and yes, at that time the firmware is not
> ready to provide the information yet.
<snip>
> > 
> > As can be seen in the current code base, iwl_mvm_tzone_get_temp()
> > will return
> > -EIO 100% of the time when the firmware doesn't support reading the

If I understad correctly this error happen 100% of the time, not only
during init. Hence seems there is an issue here, i.e. cur_ucode is not
marked correctly as IWL_UCODE_REGULAR or iwl_mvm_get_temp() fail
100% of the time (iwl_mvm_is_tt_in_fw() incorrecly return true on
Prarit device ? ).

BTW, you implement thermal_zone device, but do you also need hwmon
device? Perhaps using theramal_zone_params no_hwmon option would be
proper here?

Stanislaw
