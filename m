From: Vince Bridgers <vbridgers2013-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v3 5/9] Altera TSE: Add Miscellaneous Files for
 Altera Ethernet Driver
Date: Tue, 11 Mar 2014 19:28:53 -0500
Message-ID: <CAOwfj2Ot+ssTZgMoOoShVEUi+RkxjpPpRUfHAkP9RETm3TuUzg@mail.gmail.com>
References: <1394577791-6547-1-git-send-email-vbridgers2013@gmail.com>
	<1394577791-6547-6-git-send-email-vbridgers2013@gmail.com>
	<1394578747.28839.4.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"pawel.moll-5wv7dgnIgG8@public.gmane.org" <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	"mark.rutland-5wv7dgnIgG8@public.gmane.org" <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	"ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org" <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394578747.28839.4.camel@joe-AO722>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Joe,

On Tue, Mar 11, 2014 at 5:59 PM, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> wrote:
> On Tue, 2014-03-11 at 17:43 -0500, Vince Bridgers wrote:
>> This patch adds miscellaneous files for the Altera Ethernet Driver,
>> including ethtool support.
>
> trivial notes:
>
>> diff --git a/drivers/net/ethernet/altera/altera_tse_ethtool.c b/drivers/net/ethernet/altera/altera_tse_ethtool.c
> []
>> +static char const stat_gstrings[][ETH_GSTRING_LEN] = {
>
> static const char
>
>> +     "aFramesTransmittedOK",
>
> Why the prefix with a?

These names follow the names of the statistics found in the databook
for the Altera Triple Speed Ethernet (TSE) soft IP. I'm not
emotionally attached to these names, so will review the statistics
names and follow common usage instead. Thank you for noticing and
commenting.

>
>> +     "aFramesReceivedOK",
>
> "rx_packets" is typically used
>
>> +     "aFramesCheckSequenceErrors",
>
>> +     "aAlignmentErrors",
>> +     "aOctetsTransmittedOK",
>> +     "aOctetsReceivedOK",
>> +     "aTxPAUSEMACCtrlFrames",
>> +     "aRxPAUSEMACCtrlFrames",
>> +     "ifInErrors",
>> +     "ifOutErrors",
>> +     "ifInUcastPkts",
>> +     "ifInMulticastPkts",
>> +     "ifInBroadcastPkts",
>> +     "ifOutDiscards",
>> +     "ifOutUcastPkts",
>> +     "ifOutMulticastPkts",
>> +     "ifOutBroadcastPkts",
>> +     "etherStatsDropEvents",
>> +     "etherStatsOctets",
>> +     "etherStatsPkts",
>> +     "etherStatsUndersizePkts",
>> +     "etherStatsOversizePkts",
>> +     "etherStatsPkts64Octets",
>> +     "etherStatsPkts65to127Octets",
>> +     "etherStatsPkts128to255Octets",
>> +     "etherStatsPkts256to511Octets",
>> +     "etherStatsPkts512to1023Octets",
>> +     "etherStatsPkts1024to1518Octets",
>> +     "etherStatsPkts1519toXOctets",
>> +     "etherStatsJabbers",
>> +     "etherStatsFragments",
>
> Perhaps review all of these strings for
> unusual naming.

Will do, thanks.

>
>> +static void tse_get_regs(struct net_device *dev, struct ethtool_regs *regs,
>> +                      void *regbuf)
>> +{
>> +     int i;
>> +     struct altera_tse_private *priv = netdev_priv(dev);
>> +     u32 *tse_mac_regs = (u32 *)priv->mac_dev;
>> +     u32 *buf = (u32 *)regbuf;
>
> void * doesn't need a cast
>
>         u32 *buf = regbuf
>
> is just fine.

I'll pick this up while reviewing and updating the stats names.

Thank you for taking the time to review and provide constructive
comments. I'll address these and respin.

All the best,

Vince
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
