From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH RFC] ipw2200: select CFG80211_WEXT
Date: Mon, 22 Dec 2014 20:13:02 +0100
Message-ID: <1419275582.1890.24.camel@sipsolutions.net>
References: <1419271817.2317.12.camel@tiscali.nl>
	 (sfid-20141222_191040_534124_837C59D7)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stanislav Yakovlev <stas.yakovlev@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419271817.2317.12.camel@tiscali.nl> (sfid-20141222_191040_534124_837C59D7)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-12-22 at 19:10 +0100, Paul Bolle wrote:
> Commit 24a0aa212ee2 ("cfg80211: make WEXT compatibility unselectable")
> made it impossible to depend on CFG80211_WEXT. It does still allow to
> select that symbol. (Yes, the commit summary is confusing.)
> 
> So make IPW2200 select CFG80211_WEXT, so that the ipw2200 driver can be
> built again.
> 
> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
> ---
> Johannes,
> 
> Building v3.19-rc1 for an outdated ThinkPad X41 left me without the
> ipw2200 driver. It turns out this trivial patch is all that's needed to
> make ipw2200 buildable again.
> 
> (A similar patch would be needed for the drivers behind Kconfig symbol
> HERMES. Ie, orinico and friends.) 
> 
> I must admit that I do not fully understand your commit. (How was
> CFG80211_WEXT "marked for deprecation and removal for a little more than
> two years"?) There's some terminology confusion: what you call "select"
> I tend to call "set". Anyhow, your commit basically disables building
> ipw2200 (and apparently orinoco and friends)?
> 
> Was that your intention?
>  
>  drivers/net/wireless/ipw2x00/Kconfig | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/ipw2x00/Kconfig b/drivers/net/wireless/ipw2x00/Kconfig
> index 91c0cb3c368e..21de4fe6cf2d 100644
> --- a/drivers/net/wireless/ipw2x00/Kconfig
> +++ b/drivers/net/wireless/ipw2x00/Kconfig
> @@ -65,7 +65,8 @@ config IPW2100_DEBUG
>  
>  config IPW2200
>  	tristate "Intel PRO/Wireless 2200BG and 2915ABG Network Connection"
> -	depends on PCI && CFG80211 && CFG80211_WEXT
> +	depends on PCI && CFG80211
> +	select CFG80211_WEXT
>  	select WIRELESS_EXT

I didn't realize that this driver actually depended on this symbol - I
had been under the impression that those would still use regular wext
(WIRELESS_EXT) only.

So yeah - this makes sense. FWIW, by "selectable" I meant by the user.

johannes
