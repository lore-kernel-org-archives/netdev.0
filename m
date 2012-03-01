From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/7] net: validate MAC address directly in
 dev_set_mac_address()
Date: Thu, 01 Mar 2012 16:21:30 -0500 (EST)
Message-ID: <20120301.162130.2267876784560089802.davem@davemloft.net>
References: <1330620747-4047-1-git-send-email-danny.kukawka@bisect.de>
	<1330620747-4047-2-git-send-email-danny.kukawka@bisect.de>
	<1330624289.2609.36.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: danny.kukawka@bisect.de, eilong@broadcom.com, dkukawka@suse.de,
	eric.dumazet@gmail.com, mirq-linux@rere.qmqm.pl, jpirko@redhat.com,
	nhorman@tuxdriver.com, rdunlap@xenotime.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330624289.2609.36.camel@bwh-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 1 Mar 2012 17:51:29 +0000

> On Thu, 2012-03-01 at 17:52 +0100, Danny Kukawka wrote:
>> Validate the given MAC address directly in dev_set_mac_address()
>> if a .ndo_validate_addr function is available before calling
>> the .ndo_set_mac_address function.
>> 
>> Changed .ndo_validate_addr to take a second parameter containing
>> a sockaddr struct to be checked instead of the net_device dev_addr.
>> The behaviour of .ndo_validate_addr is now: if the second parameter
>> is NULL the net_device->dev_addr gets validate, if != NULL
>> the given parameter/sockaddr gets validated instead.
> [...]
> 
> The caller is assumed to have validated the address family, so why not
> just pass a pointer to the hardware address (u8 *), and get rid of the
> special case for NULL?
> 
> That is, dev_set_mac_address would call:
> 	ops->ndo_validate_addr(dev, sa->sa_data);
> and dev_open would call:
> 	ops->ndo_validate_addr(dev, dev->dev_addr);

Yes, this looks a lot better.
