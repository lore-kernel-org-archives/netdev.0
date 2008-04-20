From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Expose netdevice dev_id through sysfs
Date: Sat, 19 Apr 2008 18:33:41 -0700 (PDT)
Message-ID: <20080419.183341.46125500.davem@davemloft.net>
References: <1208171478.31695.58.camel@pmac.infradead.org>
	<3ae72650804140455l4bb2afc2i4c54e58f3be1f931@mail.gmail.com>
	<1208176322.31695.73.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kay.sievers@vrfy.org, md@linux.it, harald@redhat.com,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	schwidefsky@de.ibm.com
To: dwmw2@infradead.org
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <1208176322.31695.73.camel@pmac.infradead.org>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Woodhouse <dwmw2@infradead.org>
Date: Mon, 14 Apr 2008 13:32:02 +0100

> Expose dev_id to userspace, because it helps to disambiguate between
> interfaces where the MAC address is unique.
> 
> Signed-off-by: David Woodhouse <dwmw2@infradead.org>

As far as I can tell there is only one driver, s390's qeth, even
setting netdev->dev_id.

And this driver is providing netdev->dev_id uniqueness amongst qeth
device instances.

But that's not the problem we're trying to solve.

We're trying to provide uniqueness amongst all devices in the system
that are using the same MAC address.

On a Sparc system, for example, ethernet chips driven by several
different drivers can end up with the same MAC address, as the
system IDPROM specified ethernet MAC is what will be used by
default.

So we need some global scheme.  And this dev_id value would need to be
persistent.  As best as I can tell, such things aren't available.
Sure we could do something silly like use the device I/O physical
address, but that would defeat the whole purpose of making device
identification agnostic to I/O bus geography.  I could move the
card to a different slot and it would have a different dev_id.

We therefore need a more concrete and workable plan to resolve
this issue.
