From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: Re: [PATCH] sh: sh_eth: Add support ethtool
Date: Tue, 11 Jan 2011 20:54:19 +0900
Message-ID: <AANLkTikw+fcA_pvtcXLu8MENJSaO2u+wiQwRWe6Tejdp@mail.gmail.com>
References: <1294385126-3098-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
 <1294410955.4200.3.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1294410955.4200.3.camel@bwh-desktop>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/1/7 Ben Hutchings <bhutchings@solarflare.com>:
> On Fri, 2011-01-07 at 16:25 +0900, Nobuhiro Iwamatsu wrote:
>> This commit supports following functions.
>> =A0- get_drvinfo
>> =A0- get_settings
>> =A0- set_settings
>> =A0- nway_reset
>> =A0- get_msglevel
>> =A0- set_msglevel
>> =A0- get_link
>> =A0- get_strings
>> =A0- get_ethtool_stats
>> =A0- get_sset_count
>>
>> About other function, the device does not support.
>>
>> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
>> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
>> ---
>> =A0drivers/net/sh_eth.c | =A0190 +++++++++++++++++++++++++++++++++++=
+++++++++++----
>> =A01 files changed, 176 insertions(+), 14 deletions(-)
>>
>> diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
>> index 819c175..10493e8 100644
>> --- a/drivers/net/sh_eth.c
>> +++ b/drivers/net/sh_eth.c
>> @@ -32,6 +32,7 @@
>> =A0#include <linux/io.h>
>> =A0#include <linux/pm_runtime.h>
>> =A0#include <linux/slab.h>
>> +#include <linux/ethtool.h>
>> =A0#include <asm/cacheflush.h>
>>
>> =A0#include "sh_eth.h"
>> @@ -573,7 +574,7 @@ static int sh_eth_ring_init(struct net_device *n=
dev)
>> =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 /* Allocate all Rx descriptors. */
>> - =A0 =A0 rx_ringsize =3D sizeof(struct sh_eth_rxdesc) * RX_RING_SIZ=
E;
>> + =A0 =A0 rx_ringsize =3D sizeof(struct sh_eth_rxdesc) *RX_RING_SIZE=
;
>
> Please don't delete spaces just because checkpatch.pl is too stupid t=
o
> recognise a multiplication.
>
> Also, don't mix formatting cleanup with actual feature changes.
>
I see.

> [...]
>> +static const char sh_eth_gstrings_stats[][ETH_GSTRING_LEN] =3D {
>> + =A0 =A0 "rx_packets", "tx_packets", "rx_bytes", "tx_bytes", "rx_er=
rors",
>> + =A0 =A0 "tx_errors", "rx_dropped", "tx_dropped", "multicast", "col=
lisions",
>> + =A0 =A0 "rx_length_errors", "rx_over_errors", "rx_crc_errors",
>> + =A0 =A0 "rx_frame_errors", "rx_fifo_errors", "rx_missed_errors",
>> + =A0 =A0 "tx_aborted_errors", "tx_carrier_errors", "tx_fifo_errors"=
,
>> + =A0 =A0 "tx_heartbeat_errors", "tx_window_errors",
>> + =A0 =A0 /* device-specific stats */
>> + =A0 =A0 "rx_current", "tx_current",
>> + =A0 =A0 "rx_dirty", "tx_dirty",
>> +};
>> +#define SH_ETH_NET_STATS_LEN =A021
>> +#define SH_ETH_STATS_LEN =A0ARRAY_SIZE(sh_eth_gstrings_stats)
>> +
>> +static int sh_eth_get_sset_count(struct net_device *netdev, int sse=
t)
>> +{
>> + =A0 =A0 switch (sset) {
>> + =A0 =A0 case ETH_SS_STATS:
>> + =A0 =A0 =A0 =A0 =A0 =A0 return SH_ETH_STATS_LEN;
>> + =A0 =A0 default:
>> + =A0 =A0 =A0 =A0 =A0 =A0 return -EOPNOTSUPP;
>> + =A0 =A0 }
>> +}
>> +
>> +static void sh_eth_get_ethtool_stats(struct net_device *ndev,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ethtool_stats *stat=
s, u64 *data)
>> +{
>> + =A0 =A0 struct sh_eth_private *mdp =3D netdev_priv(ndev);
>> + =A0 =A0 int i;
>> +
>> + =A0 =A0 for (i =3D 0; i < SH_ETH_NET_STATS_LEN; i++)
>> + =A0 =A0 =A0 =A0 =A0 =A0 data[i] =3D ((unsigned long *)&ndev->stats=
)[i];
> [...]
>
> There is no need to duplicate net_device_stats here.
Oh, yes. thanks,

I send the patch which revised the part which you pointed out.

Best regards,
  Nobuhiro

--=20
Nobuhiro Iwamatsu
