From: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Subject: RE: [PATCH RESEND] iwlwifi, Do not implement thermal zone unless
 ucode is loaded
Date: Thu, 14 Jul 2016 09:44:22 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB3466901DA@hasmsx107.ger.corp.intel.com>
References: <1468250301-10357-1-git-send-email-prarit@redhat.com>
 <CANUX_P0AFoM5VEDWDjtvOhNbExu4T1bLWU+uS-EYqoGtu5h2bw@mail.gmail.com>
 <5783E33E.7090205@redhat.com> <1468261650.20877.14.camel@intel.com>
 <20160714092408.GA27271@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
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
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160714092408.GA27271@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> On Mon, Jul 11, 2016 at 06:27:30PM +0000, Grumbach, Emmanuel wrote:
> > I guess that works, but it seems wrong to me. Usually, registration
> > should happen only upon INIT, and yes, at that time the firmware is
> > not ready to provide the information yet.
> <snip>
> > >
> > > As can be seen in the current code base, iwl_mvm_tzone_get_temp()
> > > will return -EIO 100% of the time when the firmware doesn't support
> > > reading the
> 
> If I understad correctly this error happen 100% of the time, not only during
> init. Hence seems there is an issue here, i.e. cur_ucode is not marked
> correctly as IWL_UCODE_REGULAR or iwl_mvm_get_temp() fail 100% of the
> time (iwl_mvm_is_tt_in_fw() incorrecly return true on Prarit device ? ).

Cur_ucode will not be IWL_UCODE_REGULAR until you load the firmware which
will happen upon ifup.

> 
> BTW, you implement thermal_zone device, but do you also need hwmon
> device? Perhaps using theramal_zone_params no_hwmon option would be
> proper here?

That's an interesting direction. I'd have to check, but TBH, I am not familiar with
that code. Luca was very involved during the development but he is not available
right now. I will be back more the less when the merge window will close :)

> 
> Stanislaw
