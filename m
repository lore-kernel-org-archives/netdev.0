From: Arend van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH] brcm80211: make const array ucode_ofdm_rates static,
 reduces object code size
Date: Fri, 22 Sep 2017 18:51:43 +0200
Message-ID: <96caf646-a43c-9b78-a4a9-2becf7e74125@broadcom.com>
References: <20170922140316.12768-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Chi-Hsien Lin <chi-hsien.lin@cypress.com>,
        Wright Feng <wright.feng@cypress.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com,
        brcm80211-dev-list@cypress.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170922140316.12768-1-colin.king@canonical.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please use 'brcmsmac:' as prefix instead of 'brcm80211:'.

On 22-09-17 16:03, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> Don't populate const array ucode_ofdm_rates on the stack, instead make it
> static. Makes the object code smaller by 100 bytes:
> 
> Before:
>     text	   data	    bss	    dec	    hex	filename
>    39482	    564	      0	  40046	   9c6e	phy_cmn.o
> 
> After
>     text	   data	    bss	    dec	    hex	filename
>    39326	    620	      0	  39946	   9c0a	phy_cmn.o
> 
> (gcc 6.3.0, x86-64)

Acked-by: Arend van Spriel <arend.vanspriel@broadcom.com>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>   drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_cmn.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_cmn.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_cmn.c
> index 1c4e9dd57960..3a13d176b221 100644
> --- a/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_cmn.c
> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_cmn.c
> @@ -1916,7 +1916,7 @@ void wlc_phy_txpower_update_shm(struct brcms_phy *pi)
>   				     pi->hwpwr_txcur);
>   
>   		for (j = TXP_FIRST_OFDM; j <= TXP_LAST_OFDM; j++) {
> -			const u8 ucode_ofdm_rates[] = {
> +			static const u8 ucode_ofdm_rates[] = {
>   				0x0c, 0x12, 0x18, 0x24, 0x30, 0x48, 0x60, 0x6c
>   			};
>   			offset = wlapi_bmac_rate_shm_offset(
> 
