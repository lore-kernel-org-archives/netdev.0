From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 2/3] staging: r8188eu: Fix case where ethtype was never
 obtained and always be checked against 0
Date: Wed, 9 Apr 2014 21:51:53 +0300
Message-ID: <20140409185152.GB26890@mwanda>
References: <1397059980-11942-1-git-send-email-Larry.Finger@lwfinger.net>
 <1397059980-11942-3-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, gregkh@linuxfoundation.org,
 Stable <stable@vger.kernel.org>, netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1397059980-11942-3-git-send-email-Larry.Finger@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 09, 2014 at 11:12:59AM -0500, Larry Finger wrote:
> diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
> index 01fcabc..61084d6 100644
> --- a/drivers/staging/rtl8188eu/core/rtw_recv.c
> +++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
> @@ -551,7 +551,7 @@ static struct recv_frame *portctrl(struct adapter *adapter,
>  	struct sta_info *psta;
>  	struct sta_priv *pstapriv;
>  	struct recv_frame *prtnframe;
> -	u16	ether_type = 0;
> +	u16	ether_type;
>  	u16  eapol_type = 0x888e;/* for Funia BD's WPA issue */
>  	struct rx_pkt_attrib *pattrib;
>  	__be16 be_tmp;
> @@ -571,19 +571,17 @@ static struct recv_frame *portctrl(struct adapter *adapter,
>  
>  	RT_TRACE(_module_rtl871x_recv_c_, _drv_info_, ("########portctrl:adapter->securitypriv.dot11AuthAlgrthm=%d\n", adapter->securitypriv.dot11AuthAlgrthm));
>  
> -	if (auth_alg == 2) {
> +	if (auth_alg == dot11AuthAlgrthm_8021X) {
> +		/* get ether_type */
> +		ptr = ptr + pfhdr->attrib.hdrlen + LLC_HEADER_SIZE;
> +		memcpy(&ether_type, ptr, 2);
> +		ether_type = ntohs((unsigned short)ether_type);

This cast doesn't make sense.  u16 and unsigned short are the same
thing.  Anyway, the "ether_type" should be declared as __be16 because
it's network endian.

https://lwn.net/Articles/205624/

regards,
dan carpenter
