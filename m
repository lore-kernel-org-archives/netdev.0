From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 1/7] net: validate MAC address directly in
 dev_set_mac_address()
Date: Thu, 1 Mar 2012 17:51:29 +0000
Message-ID: <1330624289.2609.36.camel@bwh-desktop>
References: <1330620747-4047-1-git-send-email-danny.kukawka@bisect.de>
	 <1330620747-4047-2-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eilon Greenstein <eilong@broadcom.com>,
	Danny Kukawka <dkukawka@suse.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Jiri Pirko <jpirko@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Randy Dunlap <rdunlap@xenotime.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330620747-4047-2-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-03-01 at 17:52 +0100, Danny Kukawka wrote:
> Validate the given MAC address directly in dev_set_mac_address()
> if a .ndo_validate_addr function is available before calling
> the .ndo_set_mac_address function.
> 
> Changed .ndo_validate_addr to take a second parameter containing
> a sockaddr struct to be checked instead of the net_device dev_addr.
> The behaviour of .ndo_validate_addr is now: if the second parameter
> is NULL the net_device->dev_addr gets validate, if != NULL
> the given parameter/sockaddr gets validated instead.
[...]

The caller is assumed to have validated the address family, so why not
just pass a pointer to the hardware address (u8 *), and get rid of the
special case for NULL?

That is, dev_set_mac_address would call:
	ops->ndo_validate_addr(dev, sa->sa_data);
and dev_open would call:
	ops->ndo_validate_addr(dev, dev->dev_addr);

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
