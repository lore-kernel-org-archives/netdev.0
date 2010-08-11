From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 2/2] ipw2100: add WEXT scan capabilities
Date: Wed, 11 Aug 2010 18:32:42 -0500
Message-ID: <1281569562.21024.6.camel@dcbw.foobar.com>
References: <1281555063.4367.1.camel@lovely.krouter>
	 <1281555195.4367.3.camel@lovely.krouter>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Zhu Yi <yi.zhu@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Christoph Fritz <chf.fritz@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57975 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751760Ab0HKXbk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Aug 2010 19:31:40 -0400
In-Reply-To: <1281555195.4367.3.camel@lovely.krouter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-08-11 at 21:33 +0200, Christoph Fritz wrote:
> NetworkManager claims: "driver does not support SSID scans (scan_capa
> 0x00)". This patch adds scan capabilities.

NAK

It just doesn't.  Take a look at ipw2100_wx_set_scan(); there's no
handling of any SSID stuff in there.  The driver does not support
probe-scans; I'm not sure if the firmware does, but even if it does, the
driver doesn't send the SSID down to the firmware.

Compare this to the ipw2200.c set_scan() function.  It just does not
appear that the ipw2100 supports arbitrary SSIDs for direct scans, which
is why I didn't include this capability when I went around patching the
drivers a few years ago.

Dan


> Signed-off-by: Christoph Fritz <chf.fritz@googlemail.com>
> ---
>  drivers/net/wireless/ipw2x00/ipw2100.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
> index df8e535..c330da4 100644
> --- a/drivers/net/wireless/ipw2x00/ipw2100.c
> +++ b/drivers/net/wireless/ipw2x00/ipw2100.c
> @@ -6982,12 +6982,15 @@ static int ipw2100_wx_get_range(struct net_device *dev,
>  
>  	/* Event capability (kernel + driver) */
>  	range->event_capa[0] = (IW_EVENT_CAPA_K_0 |
> -				IW_EVENT_CAPA_MASK(SIOCGIWAP));
> +				IW_EVENT_CAPA_MASK(SIOCGIWAP) |
> +				IW_EVENT_CAPA_MASK(SIOCGIWSCAN));
>  	range->event_capa[1] = IW_EVENT_CAPA_K_1;
>  
>  	range->enc_capa = IW_ENC_CAPA_WPA | IW_ENC_CAPA_WPA2 |
>  		IW_ENC_CAPA_CIPHER_TKIP | IW_ENC_CAPA_CIPHER_CCMP;
>  
> +	range->scan_capa = IW_SCAN_CAPA_ESSID | IW_SCAN_CAPA_TYPE;
> +
>  	IPW_DEBUG_WX("GET Range\n");
>  
>  	return 0;


