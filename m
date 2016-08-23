From: Nicolas Iooss <nicolas.iooss_linux-oWGTIYur0i8@public.gmane.org>
Subject: Re: [PATCH 1/1] brcmfmac: fix pmksa->bssid usage
Date: Tue, 23 Aug 2016 11:30:12 +0200
Message-ID: <7fc849f7-c178-d13e-e9cf-d107a9f73c61@m4x.org>
References: <20160805203418.32162-1-nicolas.iooss_linux@m4x.org>
 <96ea6e57-79d7-d4ff-1228-6f22addd4996@m4x.org>
 <45617c4f-60b9-2587-5e29-6330ba2f40a6@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arend Van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Franky Lin <franky.lin-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Hante Meuleman <hante.meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, brcm80211-dev-list.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <45617c4f-60b9-2587-5e29-6330ba2f40a6-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 22/08/16 21:38, Arend Van Spriel wrote:
> On 22-8-2016 15:03, Nicolas Iooss wrote:
>> On 05/08/16 22:34, Nicolas Iooss wrote:
[...]
>>> Fixes: 6c404f34f2bd ("brcmfmac: Cleanup pmksa cache handling code")
>>> Cc: stable-q7rQbLoQdy39qxiX1TGQuw@public.gmane.org
> 
> Ah, so you did something wrong after all :-p. The email address should
> be 'stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org'.

Thanks for spotting this! I'll fix this address.

>>> Signed-off-by: Nicolas Iooss <nicolas.iooss_linux-oWGTIYur0i8@public.gmane.org>
>>> ---
>>>
>>> scripts/checkpatch.pl reports a warning: "Prefer ether_addr_equal() or
>>> ether_addr_equal_unaligned() over memcmp()".  Because some files in
>>> drivers/net/wireless/broadcom/brcm80211/brcmfmac/ still use memcmp()
>>> to compare addresses and because I do not know whether pmksa->bssid is
>>> always aligned, I did not follow this warning.
> 
> As most of this is done in slow path, I prefer memcmp() as I do not want
> to check alignment for minimal performance gain.

OK.

>>>  drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c | 4 ++--
>>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
>>> index 2628d5e12c64..aceab77cd95a 100644
>>> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
>>> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
>>> @@ -3884,11 +3884,11 @@ brcmf_cfg80211_del_pmksa(struct wiphy *wiphy, struct net_device *ndev,
>>>  	if (!check_vif_up(ifp->vif))
>>>  		return -EIO;
>>>  
>>> -	brcmf_dbg(CONN, "del_pmksa - PMK bssid = %pM\n", &pmksa->bssid);
>>> +	brcmf_dbg(CONN, "del_pmksa - PMK bssid = %pM\n", pmksa->bssid);
>>>  
>>>  	npmk = le32_to_cpu(cfg->pmk_list.npmk);
>>>  	for (i = 0; i < npmk; i++)
>>> -		if (!memcmp(&pmksa->bssid, &pmk[i].bssid, ETH_ALEN))
>>> +		if (!memcmp(pmksa->bssid, &pmk[i].bssid, ETH_ALEN))
> 
> I find '&pmk[i].bssid' confusing so maybe you could change it to
> '&pmk[i].bssid[0]' or 'pmk[i].bssid' as I think these two are
> essentially the same.

I agree the three ways of writing this share the same meaning. I'll send
a v2 with 'pmk[i].bssid'.
> 
> Regards,
> Arend

Thanks for your review!
Nicolas
