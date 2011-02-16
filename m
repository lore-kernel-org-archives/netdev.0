From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: Re: [PATCH v2] sh: sh_eth: Add support ethtool
Date: Wed, 16 Feb 2011 16:04:50 +0900
Message-ID: <AANLkTi=M=BdfzGVeWU-a1YA50ygxji_0Odk264xX0FLC@mail.gmail.com>
References: <1294747109-11511-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
 <1294748343.2927.57.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	yoshihiro.shimoda.uh@renesas.com, bhutchings@solarflare.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1294748343.2927.57.camel@edumazet-laptop>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/1/11 Eric Dumazet <eric.dumazet@gmail.com>:
> Le mardi 11 janvier 2011 =E0 20:58 +0900, nobuhiro.iwamatsu.yj@renesa=
s.com
> a =E9crit :
>> From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
>>
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
>
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
>
> Why is it needed to report standard device stats ?
>

I dont know that we could get standart device status from basic interfa=
ce.
I removed this.

>
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
>> + =A0 =A0 int i =3D SH_ETH_NET_STATS_LEN;
>> +
>> + =A0 =A0 memcpy(data, (unsigned long *)&ndev->stats,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 SH_ETH_NET=
_STATS_LEN * sizeof(unsigned long));
>
> This is wrong on 32bit arches.
> ndev->stats is an array of "long" values, not u64 ones.

I removed this too.

>> +
>> + =A0 =A0 /* device-specific stats */
>> + =A0 =A0 data[i++] =3D mdp->cur_rx;
>> + =A0 =A0 data[i++] =3D mdp->cur_tx;
>> + =A0 =A0 data[i++] =3D mdp->dirty_rx;
>> + =A0 =A0 data[i++] =3D mdp->dirty_tx;
>> +}
>> +
>


--=20
Nobuhiro Iwamatsu
