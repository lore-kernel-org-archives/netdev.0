From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6] (1/3) add ethtool ioctl forwarding to vlan
Date: Wed, 4 Aug 2004 09:56:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040804095640.20fd1822.davem@redhat.com>
References: <20040803105017.0774e1db@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040803105017.0774e1db@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 3 Aug 2004 10:50:17 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> When network devices are used in bridges, the bridge does an ethtool
> ioctl to pick up the speed; this doesn't work with vlans.
> This patch makes any ethtool gets forwarded to the under lying
> real device.  It seemed to make sense to do MII as well.

By changing the ifr.ifr_name field, you are going to corrupt
the return value the user will see if ':' "colon" processing
is done by dev_ioctl().

An ifreq isn't too large, just use a local copy on
vlan_dev_ioctl()'s stack.
