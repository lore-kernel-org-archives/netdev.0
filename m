From: Rick Payne <rickp@rossfell.co.uk>
Subject: multiple unicast mac address (was Re: netdev_ops retraction)
Date: Thu, 31 Jul 2003 13:49:19 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <2147483647.1059659359@fozzy.rossfell.co.uk>
References: <20030730184416.GI22222@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20030730184416.GI22222@parcelfarce.linux.theplanet.co.uk>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--On Wednesday, July 30, 2003 7:44 pm +0100 Matthew Wilcox 
<willy@debian.org> wrote:

> +       void    (*set_multicast_list)(struct net_device *dev);
> +       int     (*set_mac_address)(struct net_device *dev, void *addr);

Talking of which - is there any appetite for a patch that allows multiple 
unicast mac addresses to be set on an ethernet interface? Its certainly 
much neater for things like VRRP and HA stuff if an ethernet device is able 
to continue accepting packets for its original MAC address, as well as the 
'virtual MAC address'.

Obviously I'm not talking about generated packets (they will still take the 
MAC address from dev->dev_addr) - I'm talking about the hardware filter on 
the ethernet cards themselves. (In some cases, the software concerned may 
want to set_mac_address - thus updating dev->dev_addr, and then also add 
the original mac address to the 'unicast accept list' for instance).

Some ethernet cards seem to support this and don't care what MAC addresses 
get put in the multicast list - and I've used that technique before (on 
cards such as the eepro100 for instance). Others may have a different, not 
currently used method to set multiple unicast MAC addresses. Finally, as a 
worst last case - a card could go into promiscuous mode and filter in 
software.

Should I just start on a patch and submit it here for comment?

Rick
