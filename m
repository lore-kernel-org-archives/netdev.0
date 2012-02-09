From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: Re: [RFC][PATCH 00/50] set addr_assign_type to NET_ADDR_RANDOM if  a random mac address get assigned to a netdevice
Date: Thu, 9 Feb 2012 15:59:05 +0100
Message-ID: <201202091559.06480.danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de> <20120208145823.75f386c5@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120208145823.75f386c5@nehalam.linuxnetplumber.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mittwoch, 8. Februar 2012, Stephen Hemminger wrote:
> On Wed,  8 Feb 2012 22:10:07 +0100
>
> Danny Kukawka <danny.kukawka@bisect.de> wrote:
> > The information if a device has a random MAC address is exported
> > to the userspace via /sys/class/net/*/addr_assign_type, which
> > export net_device->addr_assign_type.
> >
> > Currently only a few driver really use dev_hw_addr_random() to
> > set addr_assign_type correctly to NET_ADDR_RANDOM.
> >
> > This patch change the drivers which set random addresses to
> > change also addr_assign_type to NET_ADDR_RANDOM.
> >
> > To reflect if the MAC was changed from userspace via SIOCSIFHWADDR,
> > which means it's no longer a random address set by the kernel,
> > this patch remove NET_ADDR_RANDOM from addr_assign_type in this
> > case.
> >
> > With this patch tools from userspace can now detect devices with
> > random MAC addresses and change them to persistent addresses if
> > needed (as e.g. in case of smsc95xx on PandaBoard).
> >
> > Maybe it makes sense to introduce a new state for addr_assign_type
> > to reflect the fact, that the MAC address was changed via a ioctl
> > from user space, e.g, with NET_ADDR_USERSPACE ?
>
> This reminds me that passing dev->dev_addr to dev_hw_addr_rrandom is
> redundant for all the instances you showed, so why is it ia parameter.

There are two places in the existing code where it's used in a different way 
in ixgbevf and igbvf, but thats changeable. I will take a look at it and 
change dev_hw_addr_random to take simply a net_device ands set everything 
directly.

> Also it should BUG() if address length is not 6 (ETH_ALEN).

Not needed if I change it to: 
static inline void dev_hw_addr_random(struct net_device *dev) 

Danny
