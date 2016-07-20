From: Jes Sorensen <Jes.Sorensen@redhat.com>
Subject: Re: [PATCH 3/3] staging/rtl8192e: avoid comparing unsigned type >= 0
Date: Wed, 20 Jul 2016 11:41:36 -0400
Message-ID: <wrfjbn1spb9r.fsf@redhat.com>
References: <20160720151818.4142386-1-arnd@arndb.de>
	<20160720152606.201775-1-arnd@arndb.de>
	<20160720152606.201775-2-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-wireless@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160720152606.201775-2-arnd@arndb.de> (Arnd Bergmann's message
	of "Wed, 20 Jul 2016 17:26:06 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> writes:
> There is one remaining warning about a type limit check in rtl8192e:
>
> staging/rtl8192e/rtl819x_TSProc.c:326:14: error: comparison is always true due to limited range of data type [-Werror=type-limits]
>
> This changes a macro into a local function to clarify the types and simplify
> the check while removing the warning.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/staging/rtl8192e/rtl819x_Qos.h    | 3 ---
>  drivers/staging/rtl8192e/rtl819x_TSProc.c | 5 +++++
>  2 files changed, 5 insertions(+), 3 deletions(-)

Looks good to me!

Acked-by: Jes Sorensen <Jes.Sorensen@redhat.com>

> diff --git a/drivers/staging/rtl8192e/rtl819x_Qos.h b/drivers/staging/rtl8192e/rtl819x_Qos.h
> index 463122db6d29..61da8f7475bb 100644
> --- a/drivers/staging/rtl8192e/rtl819x_Qos.h
> +++ b/drivers/staging/rtl8192e/rtl819x_Qos.h
> @@ -169,9 +169,6 @@ union qos_tclas {
>  	} TYPE2_8021Q;
>  };
>  
> -#define IsACValid(ac)		((ac >= 0 && ac <= 7) ? true : false)
> -
> -
>  union aci_aifsn {
>  	u8	charData;
>  
> diff --git a/drivers/staging/rtl8192e/rtl819x_TSProc.c b/drivers/staging/rtl8192e/rtl819x_TSProc.c
> index 2c8a526773ed..a966a8e490ab 100644
> --- a/drivers/staging/rtl8192e/rtl819x_TSProc.c
> +++ b/drivers/staging/rtl8192e/rtl819x_TSProc.c
> @@ -306,6 +306,11 @@ static void MakeTSEntry(struct ts_common_info *pTsCommonInfo, u8 *Addr,
>  	pTsCommonInfo->TClasNum = TCLAS_Num;
>  }
>  
> +static bool IsACValid(unsigned int tid)
> +{
> +	return tid < 7;
> +}
> +
>  bool GetTs(struct rtllib_device *ieee, struct ts_common_info **ppTS,
>  	   u8 *Addr, u8 TID, enum tr_select TxRxSelect, bool bAddNewTs)
>  {
