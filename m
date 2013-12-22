From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC] staging: r8188eu: Fix sparse warnings in core/rtw_br_ext.c
Date: Sat, 21 Dec 2013 23:37:03 -0800
Message-ID: <20131222073703.GA27638@kroah.com>
References: <1387675868-18221-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1387675868-18221-1-git-send-email-Larry.Finger@lwfinger.net>
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

On Sat, Dec 21, 2013 at 07:31:08PM -0600, Larry Finger wrote:
> Please tell me if the following fixes are appropriate. In particular, I am uncertain of
> the __force attributes.
> 
> Thanks,
> 
> Larry
> 
> 
> Sparse lists the following:
> 
>   CHECK   drivers/staging/rtl8188eu/core/rtw_br_ext.c
> drivers/staging/rtl8188eu/core/rtw_br_ext.c:1156:63: warning: restricted __sum16 degrades to integer
> drivers/staging/rtl8188eu/core/rtw_br_ext.c:1160:69: warning: incorrect type in assignment (different base types)
> drivers/staging/rtl8188eu/core/rtw_br_ext.c:1160:69:    expected restricted __sum16 [usertype] check
> drivers/staging/rtl8188eu/core/rtw_br_ext.c:1160:69:    got int
> 
> ---
>  drivers/staging/rtl8188eu/core/rtw_br_ext.c | 47 +++++++++++++++--------------
>  1 file changed, 24 insertions(+), 23 deletions(-)
> 
> diff --git a/drivers/staging/rtl8188eu/core/rtw_br_ext.c b/drivers/staging/rtl8188eu/core/rtw_br_ext.c
> index 5425bc5..54a706f 100644
> --- a/drivers/staging/rtl8188eu/core/rtw_br_ext.c
> +++ b/drivers/staging/rtl8188eu/core/rtw_br_ext.c
> 
> @@ -1153,11 +1154,11 @@ void dhcp_flag_bcast(struct adapter *priv, struct sk_buff *skb)
>  							/*  or BROADCAST flag */
>  							dhcph->flags |= htons(BROADCAST_FLAG);
>  							/*  recalculate checksum */
> -							sum = ~(udph->check) & 0xffff;
> +							sum = (__force int)(~(udph->check)) & 0xffff;
>  							sum += be16_to_cpu(dhcph->flags);
>  							while (sum >> 16)
>  								sum = (sum & 0xffff) + (sum >> 16);
> -							udph->check = ~sum;
> +							udph->check = (__force __sum16)(~sum);

I thought __force was only "needed" when trying to move between user and
kernel pointer types, I didn't think it was needed for stuff like this.

But I really don't know what __sum16 is, so I can't say for sure, sorry.

greg k-h
