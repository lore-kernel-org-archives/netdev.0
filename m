From: Stephen Hemminger <shemminger@osdl.org>
Subject: pcmcia ether drivers can't be unloaded
Date: Thu, 22 Jul 2004 10:28:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040722102843.1e8f505c@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Greg KH <greg@kroah.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It looks like pcmica modular ether (example orinoco) can never be manually unloaded because
module refcount is always 1. This comes from the owner field in the pcmcia_driver.owner
being set.

One fix is to not set owner field but then there is a hot plug/module remove
race. But the right fix seems to fix up pcmcia to be a true bus in the driver
model and have the same hotplug as other buses; usb and pci don't have the problem.
