From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [rt2x00-users] [PATCH] wireless: Remove unnessary write over of
 register 11 in rt2800lib.c
Date: Sun, 28 Sep 2014 09:09:24 +0200
Message-ID: <20140928070923.GA2087@redhat.com>
References: <1411852301-26857-1-git-send-email-yocto6@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: IvDoorn@gmail.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	linux-kernel@vger.kernel.org
To: Nicholas Krause <yocto6@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1411852301-26857-1-git-send-email-yocto6@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 27, 2014 at 05:11:41PM -0400, Nicholas Krause wrote:
> This removes the unnecessary  overwrite of register 11 in the function,
> rt2800_config_channel as we are already writing a correct value to the
> register with rt2800_rfcsr_write(rt2x00dev,11.rfcsr).
What make you sure that overwrite is unnecessary ?

> 
> Signed-off-by: Nicholas Krause <yocto6@gmail.com>
> ---
>  drivers/net/wireless/rt2x00/rt2800lib.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/drivers/net/wireless/rt2x00/rt2800lib.c b/drivers/net/wireless/rt2x00/rt2800lib.c
> index 893c9d5..fb0ae38 100644
> --- a/drivers/net/wireless/rt2x00/rt2800lib.c
> +++ b/drivers/net/wireless/rt2x00/rt2800lib.c
> @@ -2787,8 +2787,6 @@ static void rt2800_config_channel_rf55xx(struct rt2x00_dev *rt2x00dev,
>  
>  	if (rf->channel <= 14) {
>  		rt2800_rfcsr_write(rt2x00dev, 10, 0x90);
> -		/* FIXME: RF11 owerwrite ? */
> -		rt2800_rfcsr_write(rt2x00dev, 11, 0x4A);
We need a prove that remove is correct, i.e. some reference to 
vendor code or spec that current writing register twice with
different values is wrong.

NACK for the patch.

Stanislaw
