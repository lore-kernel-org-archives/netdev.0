From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next] atl1e: Atheros L1E Gigabit Ethernet driver
Date: Tue, 15 Jul 2008 21:15:14 -0700
Message-ID: <20080715211514.25848d8a@extreme>
References: <72981EBCFD196144B7C6999B9FC34A9A3EE60E9F58@SHEXMB-01.global.atheros.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "jeff@garzik.org" <jeff@garzik.org>,
	David Miller <davem@davemloft.net>,
	"jcliburn@gmail.com" <jcliburn@gmail.com>,
	"parag.warudkar@gmail.com" <parag.warudkar@gmail.com>,
	Willy Tarreau <w@1wt.eu>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jie Yang <Jie.Yang@Atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:49589 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750806AbYGPEPQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 00:15:16 -0400
In-Reply-To: <72981EBCFD196144B7C6999B9FC34A9A3EE60E9F58@SHEXMB-01.global.atheros.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Jul 2008 11:28:21 +0800
Jie Yang <Jie.Yang@Atheros.com> wrote:

> From: Jie Yang <jie.yang@atheros.com>
> 
> Full patch for the Atheros L1E Gigabit Ethernet driver.
> Supportring AR8121, AR8113 and AR8114
> 
> Signed-off-by: Jie Yang <jie.yang @atheros.com>
>
> +
> +struct atl1e_recv_ret_status {
> +       u16 seq_num;
> +       u16 hash_lo;
> +       __le32  word1;
> +       u16 pkt_flag;
> +       u16 err_flag;
> +       u16 hash_hi;
> +       u16 vtag;
> +} __attribute__((packed));

No need for packed if structure has no holes. And compiler is too stupid
to know that and generates worse code.

> +typedef enum {
> +       atl1e_10_half = 0,
> +       atl1e_10_full = 1,
> +       atl1e_100_half = 2,
> +       atl1e_100_full = 3
> +} atl1e_speed_duplex_type;

enum's are good, typedef's are bad.  Kernel style is not to use typedef's
except in a very few limited places like locking.


...

> +#ifdef module_param_array
> +               if (num_media_type > bd) {
> +#endif

shouldn't need to ifdef like that?? module_param_array is part of 2.6 always.

> +                       val = media_type[bd];
> +                       atl1e_validate_option(&val, &opt, pdev);
> +                       adapter->hw.media_type = (u16) val;
> +#ifdef module_param_array
> +               } else {
> +                       adapter->hw.media_type = (u16)(opt.def);
> +               }
> +#endif
> +       }
> +}
> +
> diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
> index e74b14a..9388130 100644
> --- a/include/linux/pci_ids.h
> +++ b/include/linux/pci_ids.h
> @@ -2181,6 +2181,7 @@
> 
>  #define PCI_VENDOR_ID_ATTANSIC         0x1969
>  #define PCI_DEVICE_ID_ATTANSIC_L1      0x1048
> +#define PCI_DEVICE_ID_ATTANSIC_L1E     0x1026

Don't add pci_ids just put in driver. Jeff made that decision because
the number of id's was just growing too large.
