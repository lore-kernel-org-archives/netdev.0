From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC 2/2] net: Add support for NTB virtual ethernet device
Date: Sat, 14 Jul 2012 10:30:33 +0200
Message-ID: <20120714083033.GA1676@minipsycho.orion>
References: <1342215900-3358-1-git-send-email-jon.mason@intel.com>
 <1342215900-3358-2-git-send-email-jon.mason@intel.com>
 <20120713231403.GA1712@minipsycho.orion>
 <20120714055034.GB4808@jonmason-lab>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, Dave Jiang <dave.jiang@intel.com>
To: Jon Mason <jon.mason@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:42508 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757386Ab2GNIah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2012 04:30:37 -0400
Received: by wgbfm10 with SMTP id fm10so1149683wgb.1
        for <netdev@vger.kernel.org>; Sat, 14 Jul 2012 01:30:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20120714055034.GB4808@jonmason-lab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Jul 14, 2012 at 07:50:35AM CEST, jon.mason@intel.com wrote:
>On Sat, Jul 14, 2012 at 01:14:03AM +0200, Jiri Pirko wrote:
>> Fri, Jul 13, 2012 at 11:45:00PM CEST, jon.mason@intel.com wrote:
>> >A virtual ethernet device that uses the NTB transport API to send/receive data.
>> >
>> >Signed-off-by: Jon Mason <jon.mason@intel.com>
>> >---
>> > drivers/net/Kconfig      |    4 +
>> > drivers/net/Makefile     |    1 +
>> > drivers/net/ntb_netdev.c |  411 ++++++++++++++++++++++++++++++++++++++++++++++
>> > 3 files changed, 416 insertions(+), 0 deletions(-)
>> > create mode 100644 drivers/net/ntb_netdev.c

<snip>

>> >+
>> >+static const struct net_device_ops ntb_netdev_ops = {
>> >+	.ndo_open = ntb_netdev_open,
>> >+	.ndo_stop = ntb_netdev_close,
>> >+	.ndo_start_xmit = ntb_netdev_start_xmit,
>> >+	.ndo_change_mtu = ntb_netdev_change_mtu,
>> >+	.ndo_tx_timeout = ntb_netdev_tx_timeout,
>> >+	.ndo_set_mac_address = eth_mac_addr,
>> 
>> Does your device support mac change while it's up and running?
>
>It's virtual ethernet, so there is no hardware limitation, only what is acceptable for the remote side to receive.

In that case, it would be good to do:
dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;

This enables mac change in eth_mac_addr() when iface is running.

<snip>

>> >+
>> >+static int __init ntb_netdev_init_module(void)
>> >+{
>> >+	struct ntb_netdev *dev;
>> >+	int rc;
>> >+
>> >+	pr_info("%s: Probe\n", KBUILD_MODNAME);
>> >+
>> >+	netdev = alloc_etherdev(sizeof(struct ntb_netdev));
>> 
>> I might be missing something but this place (module init) does not seems
>> like a good place to do alloc_etherdev(). Do you want to support only
>> one netdevice instance?
>> 
>> Anyway, I think that using "static netdev" should be avoided in any case.
>> 
>
>It would fail the probe if there is no underlying ntb hardware, but it would make sense to check for that before allocing the etherdev.

But isn't there possible to have multiple ntb hardware devices? It would make
sense to register ntb device here with ntb core and let the core call
probe which would actually create new netdev.

Is there a limitation that one underlying ntb hardware ~ one ntb netdevice?

Thanks,
Jiri
