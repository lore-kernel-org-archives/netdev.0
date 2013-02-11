From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 04/10] igb: Fix for sparse warning in
 igb_get_i2c_client
Date: Mon, 11 Feb 2013 17:05:55 +0000
Message-ID: <1360602355.2701.5.camel@bwh-desktop.uk.solarflarecom.com>
References: <1360319958-10497-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1360319958-10497-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:7118 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757621Ab3BKRGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 12:06:14 -0500
In-Reply-To: <1360319958-10497-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-08 at 02:39 -0800, Jeff Kirsher wrote:
> From: Carolyn Wyborny <carolyn.wyborny@intel.com>
> 
> This patch changes definition of i2c_client in igb_get_i2c_client to static
> to prevent sparse warning.

So, in order to fix the warning:

drivers/net/ethernet/intel/igb/igb_main.c:7611:19: warning: symbol 'igb_get_i2c_client' was not declared. Should it be static?

you don't touch the function declaration, but instead make a local
variable static.  This doesn't fix the warning, but does introduce a
race condition...

Ben.

> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index c19a35c..ebf8384 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -7732,7 +7732,7 @@ igb_get_i2c_client(struct igb_adapter *adapter, u8 dev_addr)
>  {
>  	ulong flags;
>  	struct igb_i2c_client_list *client_list;
> -	struct i2c_client *client = NULL;
> +	static struct i2c_client *client;
>  	struct i2c_board_info client_info = {
>  		I2C_BOARD_INFO("igb", 0x00),
>  	};

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
