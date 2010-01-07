From: J K Cliburn <jcliburn@gmail.com>
Subject: Re: [PATCH 1/1] NET: atlx, fix memory leak
Date: Wed, 6 Jan 2010 18:28:30 -0600
Message-ID: <20100106182830.4bd861fe@gmail.com>
References: <1262796856-21919-1-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	jirislaby@gmail.com, Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>,
	atl1-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756167Ab0AGA2i@vger.kernel.org>
In-Reply-To: <1262796856-21919-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed,  6 Jan 2010 17:54:16 +0100
Jiri Slaby <jslaby@suse.cz> wrote:

> Stanse found a memory leak in atl2_get_eeprom. eeprom_buff is not
> freed/assigned on all paths. Fix that.

Acked by: Jay Cliburn <jcliburn@gmail.com>

> 
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> Cc: Jay Cliburn <jcliburn@gmail.com>
> Cc: Chris Snook <chris.snook@gmail.com>
> Cc: Jie Yang <jie.yang@atheros.com>
> Cc: atl1-devel@lists.sourceforge.net
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> ---
>  drivers/net/atlx/atl2.c |    7 +++++--
>  1 files changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
> index c0451d7..ec52529 100644
> --- a/drivers/net/atlx/atl2.c
> +++ b/drivers/net/atlx/atl2.c
> @@ -1959,12 +1959,15 @@ static int atl2_get_eeprom(struct net_device
> *netdev, return -ENOMEM;
>  
>  	for (i = first_dword; i < last_dword; i++) {
> -		if (!atl2_read_eeprom(hw, i*4,
> &(eeprom_buff[i-first_dword])))
> -			return -EIO;
> +		if (!atl2_read_eeprom(hw, i*4,
> &(eeprom_buff[i-first_dword]))) {
> +			ret_val = -EIO;
> +			goto free;
> +		}
>  	}
>  
>  	memcpy(bytes, (u8 *)eeprom_buff + (eeprom->offset & 3),
>  		eeprom->len);
> +free:
>  	kfree(eeprom_buff);
>  
>  	return ret_val;
