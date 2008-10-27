From: "Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
Subject: Re: bisected: 2.6.28-rc broke my iwl4965 wireless
Date: Mon, 27 Oct 2008 09:38:12 -0700
Message-ID: <20081027163812.GB6377@tesla>
References: <20081025222208.1d2a2c8b@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Luis Rodriguez <Luis.Rodriguez-R2DSYHpuZhhBDgjK7y7TUQ@public.gmane.org>,
	"torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081025222208.1d2a2c8b-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 25, 2008 at 10:22:08PM -0700, Arjan van de Ven wrote:
> [resend, first version got corrupted]
> 
> 2.6.28-rc1 broke my (intel 4965) wireless, and I've bisected it down to
> the commit below..... something's fishy with this...
> 
> 
> b2e1b30290539b344cbaff0d9da38012e03aa347 is first bad commit
> commit b2e1b30290539b344cbaff0d9da38012e03aa347
> Author: Luis R. Rodriguez <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
> Date:   Tue Sep 9 23:19:48 2008 -0700
> 
>     cfg80211: Add new wireless regulatory infrastructure
> 
>     This adds the new wireless regulatory infrastructure. The
>     main motiviation behind this was to centralize regulatory
>     code as each driver was implementing their own regulatory solution,
>     and to replace the initial centralized code we have where:
> 
>     * only 3 regulatory domains are supported: US, JP and EU
>     * regulatory domains can only be changed through module parameter
>     * all rules were built statically in the kernel
> 
>     We now have support for regulatory domains for many countries
>     and regulatory domains are now queried through a userspace agent
>     through udev allowing distributions to update regulatory rules
>     without updating the kernel.
> 
>     Each driver can regulatory_hint() a regulatory domain
>     based on either their EEPROM mapped regulatory domain value to a
>     respective ISO/IEC 3166-1 country code or pass an internally built
>     regulatory domain. We also add support to let the user set the
>     regulatory domain through userspace in case of faulty EEPROMs to
>     further help compliance.
> 
>     Support for world roaming will be added soon for cards capable of
>     this.
> 
>     For more information see:
> 
>     http://wireless.kernel.org/en/developers/Regulatory/CRDA
> 
>     For now we leave an option to enable the old module parameter,
>     ieee80211_regdom, and to build the 3 old regdomains statically
>     (US, JP and EU). This option is CONFIG_WIRELESS_OLD_REGULATORY.
>     These old static definitions and the module parameter is being
>     scheduled for removal for 2.6.29. Note that if you use this
>     you won't make use of a world regulatory domain as its pointless.
>     If you leave this option enabled and if CRDA is present and you
>     use US or JP we will try to ask CRDA to update us a regulatory
>     domain for us.
> 
>     Signed-off-by: Luis R. Rodriguez <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
>     Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

Arjan,

so newer kernels require CRDA and iw to set regulatory domain,
otherwise only the world regulatory domain is set so if your AP
is not in the world regulatory domain it won't connect. To enable
the other channels you need CRDA and iw installed.

http://wireless.kernel.org/en/developers/Regulatory/CRDA
http://wireless.kernel.org/en/users/Documentation/iw

Drivers can also hint to CRDA as per the API a country and in those cases
only CRDA is required, however right now only zd1211rw is using this
hint, work on the other drivers is in progress so for now calling iw
for your country is required. What is expected is in the future
wpa_supplicant will carry a country config element and it hints it.

Additionally if the old behaviour is desired for now (until distributions
catch up and add CRDA) CONFIG_WIRELESS_OLD_REGULATORY can be enabled
and you'll get the old behaviour of defaulting to country "US".

Please let me know if there are any issues.

  Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
