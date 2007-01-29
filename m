From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC PATCH 1/6] invisible network devices
Date: Mon, 29 Jan 2007 10:28:14 -0800
Message-ID: <20070129102814.6385ad2d@freekitty>
References: <20070129184707.885764375.midnight@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Stephen Hemminger <shemminger@osdl.org>,
	David Miller <davem@davemloft.net>
To: Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:49859 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752559AbXA2SbN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 13:31:13 -0500
In-Reply-To: <20070129184707.885764375.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 29 Jan 2007 18:48:06 +0100 (CET)
Jiri Benc <jbenc@suse.cz> wrote:

> The d80211 stack needs a network interface (called 'wmaster') used for
> communication with the hardware (it has 802.11 qdisc attached which perform
> MAC level QoS). This interface is not intended for users and it confuses
> them.
> 
> As a short time solution, this patch allows net_device to be registered as
> "invisible". This means it is not in the dev name hash list, its ifindex is
> -1 and protocols are not notified about its registration/unregistration.
> 
> Signed-off-by: Jiri Benc <jbenc@suse.cz>
>

Maybe code would be cleaner if you just could do:
	register_netdevice(mydev);

	cloak_netdevice(mydev);


And cloak_netdevice() just removed the network device from the 
name table.  I would rather keep it with a real ifindex and in the
device list, so that if the interface is miss used or the device
is referenced by other devices, we don't see unexpected surprises
like oops.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
