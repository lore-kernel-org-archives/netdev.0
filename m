From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 05/23] e1000: rename flow control symbols
Date: Tue, 19 Sep 2006 15:11:50 -0400
Message-ID: <451040F6.1060902@pobox.com>
References: <20060919172623.4605.56860.stgit@gitlost.site> <20060919172842.4605.41117.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51642 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751920AbWISTLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 15:11:54 -0400
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20060919172842.4605.41117.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> --- a/drivers/net/e1000/e1000_hw.h
> +++ b/drivers/net/e1000/e1000_hw.h
> @@ -90,15 +90,6 @@ typedef enum {
>      e1000_100_full = 3
>  } e1000_speed_duplex_type;
>  
> -/* Flow Control Settings */
> -typedef enum {
> -    e1000_fc_none = 0,
> -    e1000_fc_rx_pause = 1,
> -    e1000_fc_tx_pause = 2,
> -    e1000_fc_full = 3,
> -    e1000_fc_default = 0xFF
> -} e1000_fc_type;
> -
>  struct e1000_shadow_ram {
>      uint16_t    eeprom_word;
>      boolean_t   modified;
> @@ -1376,7 +1367,7 @@ struct e1000_hw {
>      struct e1000_shadow_ram *eeprom_shadow_ram;
>      uint32_t flash_bank_size;
>      uint32_t flash_base_addr;
> -    e1000_fc_type fc;
> +    uint32_t fc;
>      e1000_bus_speed bus_speed;
>      e1000_bus_width bus_width;
>      e1000_bus_type bus_type;
> @@ -1930,6 +1921,13 @@ struct e1000_hw {
>  #define E1000_FCRTL_RTL  0x0000FFF8     /* Mask Bits[15:3] for RTL */
>  #define E1000_FCRTL_XONE 0x80000000     /* Enable XON frame transmission */
>  
> +/* Flow Control Settings */
> +#define E1000_FC_NONE     0
> +#define E1000_FC_RX_PAUSE 1
> +#define E1000_FC_TX_PAUSE 2
> +#define E1000_FC_FULL     3
> +#define E1000_FC_DEFAULT  0xFF


NAK.  Goes from enum to #define, which loses type information and 
obfuscates things when inside a debugger (or other tool knowledgable of 
source code symbols).

