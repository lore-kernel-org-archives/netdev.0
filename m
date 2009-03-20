From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH]: sunvnet netdev ops conversion...
Date: Fri, 20 Mar 2009 15:19:50 +0100
Message-ID: <20090320141949.GA1031@psychotron.englab.brq.redhat.com>
References: <20090320.005205.65922171.davem@davemloft.net> <49C35443.8020604@cn.fujitsu.com> <20090320.013448.251351318.davem@davemloft.net> <87prgcju7v.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:40566 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752074AbZCTOUG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2009 10:20:06 -0400
Content-Disposition: inline
In-Reply-To: <87prgcju7v.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ri, Mar 20, 2009 at 12:43:00PM CET, bjorn@mork.no wrote:
>David Miller <davem@davemloft.net> writes:
>> From: Yang Hongyang <yanghy@cn.fujitsu.com>
>> Date: Fri, 20 Mar 2009 16:30:59 +0800
>>
>>> David Miller wrote:
>>> > Committed to net-next-2.6...
>>> >=20
>>> > sunvnet: Convert to net_device_ops.
>>>=20
>>> I noticed that there are other drivers's  net_device_ops=20
>>> need to be converted,is these convert nessary?
>>
>> Not necessary, but desirable.  Once all drivers are
>> converted we can remove the compatability code.
>
>Just thinking... Would it make sense, at some point before removing th=
e
>compatibility layer, to add tests for partial conversions?  I noticed
>the sungem bug just fixed by Stephen Hemminger=20
>( http://permalink.gmane.org/gmane.linux.network/122756 )
>which could have been caught by the patch below.
>
>This will also ease the transition of "driver sets", like usbnet and
>it's children, where a number of drivers need to make the conversion
>together.  Don't know if that's a big problem, but it did stop my firs=
t
>attempt to convert usbnet because I was uncertain whether I had caught
>all of the necessary mini driver conversions.
>
>Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>
>---
>
> net/core/dev.c |   28 ++++++++++++++++++++++++++++
> 1 files changed, 28 insertions(+), 0 deletions(-)
>
>diff --git a/net/core/dev.c b/net/core/dev.c
>index f112970..ad3e780 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -4359,6 +4359,34 @@ int register_netdevice(struct net_device *dev)
> 	 * This is temporary until all network devices are converted.
> 	 */
> 	if (dev->netdev_ops) {
>+		/* drivers using netdev_ops should not set any of these */
>+		if (dev->init ||
>+		    dev->uninit ||
>+		    dev->open ||
>+		    dev->change_rx_flags ||
>+		    dev->set_rx_mode ||
>+		    dev->set_multicast_list ||
>+		    dev->set_mac_address ||
>+		    dev->validate_addr ||
>+		    dev->do_ioctl ||
>+		    dev->set_config ||
>+		    dev->change_mtu ||
>+		    dev->neigh_setup ||
>+		    dev->tx_timeout ||
>+		    dev->get_stats ||
>+		    dev->vlan_rx_register ||
>+		    dev->vlan_rx_add_vid ||
>+		    dev->vlan_rx_kill_vid
>+#ifdef CONFIG_NET_POLL_CONTROLLER
>+		    || dev->poll_controller
>+#endif
>+			) {
>+			char drivername[64];
>+
>+			pr_info("%s (%s): mixing netdev_ops and old API\n",
>+				dev->name, netdev_drivername(dev, drivername,=20
>+							     64));
>+		}
> 		netdev_resync_ops(dev);
> 	} else {
> 		char drivername[64];
>
cc'ing Dave.

This seems like a good idea. It would make it more visible. Besides, it=
's
temporary so why not?

Jirka
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
