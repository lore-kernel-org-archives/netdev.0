From: "Ivo Van Doorn" <ivdoorn@gmail.com>
Subject: Re: drivers/net/wireless/d80211: Check configuration type in hw->config_interface.
Date: Wed, 19 Jul 2006 23:13:35 +0200
Message-ID: <a32f33a40607191413k5cab2766u4fc4ee8b4f6c4088@mail.gmail.com>
References: <44BE958C.4030401@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:25727 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1030314AbWGSVNg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jul 2006 17:13:36 -0400
Received: by py-out-1112.google.com with SMTP id s49so477353pyc
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2006 14:13:35 -0700 (PDT)
To: "Jean-Mickael Guerin" <jean-mickael.guerin@6wind.com>
In-Reply-To: <44BE958C.4030401@6wind.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> This patch prevents a NULL pointer dereferencing in AP mode:
> ieee80211_if_config will set conf->bssid only if device is of type STA
> or IBSS.
> I see it using following commands right after module loading (with rt61)
> # iwconfig wlan0 mode Master
> # ifconfig wlan0 up

When submitting a patch, please state what drivers you are really changing,
your mail subject suggested a change to the dscape stack itself.
Since I look at those patches at an irregular basis, while I am always
checking for rt2x00 related patches I could have missed this one.
Especially when you don't CC the driver maintainers about the patch
for their drivers.
Also I think most people would prefer if you split up patches when it
affects multiple drivers,
in this case rt2x00 and adm8211.

As for the patch itself, see my comments below. ;)

> diff --git a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
> b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
> index 946cf86..1d45851 100644
> --- a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
> +++ b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
> @@ -1877,7 +1877,9 @@ rt2400pci_config_interface(struct net_de
>      if (rt2x00pci->type == IEEE80211_IF_TYPE_MNTR)
>          return 0;
>
> -    rt2400pci_config_bssid(rt2x00pci, conf->bssid);
> +    if (conf->type == IEEE80211_IF_TYPE_STA ||
> +        conf->type == IEEE80211_IF_TYPE_IBSS)
> +        rt2400pci_config_bssid(rt2x00pci, conf->bssid);

Should rt2400pci_config_bssid not simply run a check to see if the
bssid argument is valid?
This would prevent the risk of having a similar problem when the
function is called from somewhere else as well.

Same comment applies for rt2500pci and rt61pci.

Any particular reason why you applied this change to PCI drivers in
rt2x00 only and not to the USB drivers?

Ivo
