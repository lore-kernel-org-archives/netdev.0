From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH net-next] cdc_ether: Improve ZTE MF823/831/910 handling
Date: Mon, 18 Jul 2016 15:01:26 +0200
Message-ID: <1468846886.2280.6.camel@suse.com>
References: <1468844691-8222-1-git-send-email-kristian.evensen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59303 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750969AbcGRNFs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2016 09:05:48 -0400
In-Reply-To: <1468844691-8222-1-git-send-email-kristian.evensen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-07-18 at 14:24 +0200, Kristian Evensen wrote:
> The firmware in the ZTE MF823/831/910 modems/mifis use OS fingerprinting to
> determine which type of device to export. In addition, these devices export
> a REST API which can also be used to control the type of device. So far, on
> Linux, the devices have been seen as RNDIS or CDC Ether.
> 
> When CDC Ether is used, devices of the same type are, as with RNDIS,
> exported with the same, bogus random MAC address. In addition, the devices

Please explain. If the MAC is random, I fail to see why the host would
be any better at making up a MAC.

> (at least on all firmware revisions I have found) use this MAC when sending
> traffic routed from external networks. And as a final feature, the devices
> sometimes export the link state incorrectly.
> 
> This patch tries to improve the handling of these devices by doing the
> following:
> 
> * If a random MAC is read from device, then generate a new random MAC
> address. This fix will apply to all devices using cdc_ether, but that
> should be ok as we will also fix similar mistakes from other
> manufacturers.

I am not really happy with this.

If this is specific to the device a quirk should be used. If it is a
truly generic misdesign, it does not belong into cdc-ether. It should go
into the generic layer.

> * The MF823/MF832/MF910 sometimes export cdc carrier on twice on connect
> (the correct behavior is off then on). Work around this by manually setting
> carrier to off if an on-notification is received and the NOCARRIER-bit is
> not set.
> 
> This change will also affect all devices, but as with the MAC-fix it should
> take care of similar mistakes. I tried to think of/look/test for
> problems/regressions that could be introduced by this behavior, but could
> not find any. However, my familiarity with this code path is not that
> great, so there could be something I have overlooked.

Looks OK

> * Add an rx_fixup-function (and a new driver info-struct) which is used by
> these three devices (identified either as PID 0x1405 or 0x1408). The
> rx_fixup-function replaces the destination MAC address in the skb with that
> of the device. I have not seen a revision of these three device that
> behaves correctly (i.e., sets the right destination MAC), so I chose not to
> do any comparison with for example the known, bogus addresses.

Looks OK

	Regards
		Oliver
