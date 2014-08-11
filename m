From: Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>
Subject: Re: [PATCH] allow setting wiphy.perm_addr after driver probe
Date: Mon, 11 Aug 2014 13:40:45 -0700
Message-ID: <1407789645.28221.68.camel@chimera>
References: <1407780269.28221.63.camel@chimera>
	 <54DF22CF-59D7-4633-A625-896F58C26A64@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org Wireless"
	<linux-wireless@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54DF22CF-59D7-4633-A625-896F58C26A64@holtmann.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-08-11 at 13:25 -0700, Marcel Holtmann wrote:
> isn't this dangerous to just allow writing to wiphy.perm_addr via
> sysfs. We ran into the same issue with Bluetooth and ROM only devices
> that have to unique address. Doing this via sysfs seems the wrong
> approach. It is messy and full of potential race conditions. I clearly
> opted against the sysfs solution for Bluetooth. Instead we build an
> infrastructure that allowed doing it cleanly via the Bluetooth mgmt
> API. Controllers that have no unique address are brought up as
> unconfigured and userspace clearly knows that it has to take steps to
> get an address programmed into the controller.

My inclination is to agree; however, this does not exist for WiFi and
implementing it would require modifying every single driver.

> And I think something similar should be done for WiFi. It might be
> better to not create the initial wlan0 netdev interface if the
> hardware has not a single unique address available. That way the
> supplicant can just either get one from the flash filesystem or make
> up a proper random one before creating the netdev interface.
> 
The initial wlan0 netdev interface is *not* created, but the PHY records
a MAC address that cannot be overriden at the level that this sysfs node
reads. Perhaps a compromise would be to create a single new syscall to
write to it?
