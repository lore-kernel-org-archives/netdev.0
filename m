From: Pedro Ramalhais <ramalhais@serrado.net>
Subject: Re: Updated WE-18 (WPA) proposal
Date: Tue, 31 Aug 2004 01:49:47 +0100
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Message-ID: <1093913355.1487.10.camel@rootix>
References: <20040830045441.GA7415@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jean Tourrilhes <jt@hpl.hp.com>, netdev@oss.sgi.com,
	hostap@shmoo.com
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: Jouni Malinen <jkmaline@cc.hut.fi>
In-Reply-To: <20040830045441.GA7415@jm.kir.nu>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://sisyphus.iocaine.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-08-30 at 05:54, Jouni Malinen wrote:
> Finally, I had enough time to implement and test the proposed WE-18
> (WPA) changes with Host AP driver and wpa_supplicant. This testing was
> indeed needed since number of issues showed up. I have made an updated
> version of the WE-18 proposal that seems to work with
> hostap and wpa_supplicant (current development snapshot from
> http://hostap/epitest.fi/). I have not yet verified how much of
> interface needed for hostapd could be moved to these new parts of WE-18
> instead of the currently used private ioctls.
> 
> Since WE-17 has apparently not yet been merged all the way into
> linux-2.6 tree, the patch below is against Linux 2.6.8.1 that has been
> patched with WE-17 patch (http://www.hpl.hp.com/personal/
> Jean_Tourrilhes/Linux/iw268_we17-10.diff). This should be quite close
> to what the final WE-18 would be diffed against. This WE-18 patch is
> still experimental and it may still need to be changed (i.e., this
> should not yet be merged into linux-2.6).
> 
> Change log against the latest WE-18 proposal (http://www.hpl.hp.com/
> personal/Jean_Tourrilhes/Linux/iw_we18-3.diff):
> 
> - replaced optional parameter (iw_point) to SIOCSIWSCAN with a new ioctl
>   (SIOCSIWSCANEXT) since the previous design was not really backwards
>   compatible (e.g., 'iwlist wlan0 scan' did not work)
> - replaced IWEVWPAIE/IWEVRSNIE with more generic IWEVGENIE which can
>   also be used with non-WPA (e.g., IEEE 802.11e/WMM) IEs; in addition,
>   fixed the type for this event to be IW_HEADER_TYPE_POINT (was _PARAM)
> - use larger IW_GENERIC_IE_MAX (256->1024) to be able to handle possible
>   needs for future IEEE 802.11 amendments
> - added new IW_AUTH_INDEX parameters IW_AUTH_WPA_ENABLED and
>   IW_AUTH_RX_UNENCRYPTED_EAPOL that were missing from the functionality
>   needed by wpa_supplicant interface
> - changed IW_AUTH_WPA_VERSION, IW_AUTH_PAIRWISE_CIPHER,
>   IW_AUTH_GROUP_CIPHER, and IW_AUTH_KEY_MGMT to bit fields
> - added LEAP to IW_AUTH_80211_AUTH_ALG values
> - added IW_ENCODE_EXT_SET_TX_KEY (set key value and mark key as default
>   TX key with one ioctl)
> - added some more comments to areas that were unclear (have generated
>   questions)
> - added min_tokens values for SIOCSIWENCODEEXT and SIOCGIWENCODEEXT
> 
> Question: is length field in struct iw_point in bytes or tokens
> (token_size bytes)? I assumed it was in bytes, but this did not work
> very well with WE ioctls that had token_size != 1; I made SIOCSIWSCANEXT
> use token_size = 1 for now, but it could be replaced to be
> sizeof(struct) and min_tokens=max_tokesn=1 once this question is
> resolved.

Hi Jouni and Jean!

#define IW_AUTH_RX_UNENCRYPTED_EAPOL   8
I think this define isn't needed because you can get the same
information from IW_AUTH_KEY_MGMT:
#define IW_AUTH_KEY_MGMT_802_1X        1
#define IW_AUTH_KEY_MGMT_PSK   2
because if IW_AUTH_KEY_MGMT_802_1X || IW_AUTH_KEY_MGMT_PSK , then you
want to pass unencrypted EAPOL packets.

Likewise for IW_AUTH_WPA_ENABLED which you can get from
IW_AUTH_WPA_VERSION:
/* IW_AUTH_WPA_VERSION values */
#define IW_AUTH_WPA_VERSION_DISABLED    0
#define IW_AUTH_WPA_VERSION_WPA         1
#define IW_AUTH_WPA_VERSION_WPA2        2
If IW_AUTH_WPA_VERSION == IW_AUTH_WPA_VERSION_DISABLED then WPA is
disabled, else if IW_AUTH_WPA_VERSION_WPA || IW_AUTH_WPA_VERSION_WPA2
then it's enabled.

Thanks!
-- 
Pedro Ramalhais <ramalhais@serrado.net>
