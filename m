From: Anish Bhatt <anish@chelsio.com>
Subject: RE: [PATCH 3] scsi: fix build errors, SCSI_FC_ATTRS needs to depend
 on SCSI && NET
Date: Tue, 16 Sep 2014 03:00:21 +0000
Message-ID: <525DB349B3FB5444AE057A887CB2A8D88EBB11@nice.asicdesigners.com>
References: <1410813921-24400-1-git-send-email-anish@chelsio.com>
 <1410813921-24400-2-git-send-email-anish@chelsio.com>,<5417825A.4050902@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"mchan@broadcom.com" <mchan@broadcom.com>,
	"eddie.wai@broadcom.com" <eddie.wai@broadcom.com>,
	"jim.epost@gmail.com" <jim.epost@gmail.com>
To: Randy Dunlap <rdunlap@infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"JBottomley@parallels.com" <JBottomley@parallels.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <5417825A.4050902@infradead.org>
Content-Language: en-US
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From : Randy Dunlap [rdunlap@infradead.org]
> Sent: Monday, September 15, 2014 5:20 PM
> To: Anish Bhatt; netdev@vger.kernel.org; JBottomley@parallels.com; David Miller
> Cc: linux-scsi@vger.kernel.org; mchan@broadcom.com; eddie.wai@broadcom.com; jim.epost@gmail.com
> Subject: [PATCH 3] scsi: fix build errors, SCSI_FC_ATTRS needs to depend on SCSI && NET
>
> From: Randy Dunlap <rdunlap@infradead.org>
>
> Fix build errors when CONFIG_SCSI_NETLINK is enabled but
> CONFIG_NET is not enabled:
>
> drivers/built-in.o: In function `scsi_nl_rcv_msg':
> scsi_netlink.c:(.text+0x1850fa): undefined reference to `netlink_ack'
> scsi_netlink.c:(.text+0x185105): undefined reference to `skb_pull'
> scsi_netlink.c:(.text+0x18515d): undefined reference to `netlink_capable'
> drivers/built-in.o: In function `scsi_netlink_init':
> (.text+0x185244): undefined reference to `init_net'
> drivers/built-in.o: In function `scsi_netlink_init':
> (.text+0x185258): undefined reference to `__netlink_kernel_create'
> drivers/built-in.o: In function `scsi_netlink_exit':
> (.text+0x185291): undefined reference to `netlink_kernel_release'
>
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>

Doesn't fix make warnings, but SCSI_FC_ATTRS can no longer be selected without
NET. Though both ia64 and powerpc emit a lot of unmet dependency warnings as is 
on defconfig

Tested-by: Anish Bhatt <anish@chelsio.com>
> ---
>  drivers/scsi/Kconfig |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> Based on Anish's previous SCSI_NETLINK patch.
> Sorry about missing this one.
>
> --- lnx-317-rc5.orig/drivers/scsi/Kconfig
> +++ lnx-317-rc5/drivers/scsi/Kconfig
> @@ -257,7 +257,7 @@ config SCSI_SPI_ATTRS
>
>  config SCSI_FC_ATTRS
>         tristate "FiberChannel Transport Attributes"
> -       depends on SCSI
> +       depends on SCSI && NET
>         select SCSI_NETLINK
>         help
>           If you wish to export transport-specific information about
