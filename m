From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: routing question under invisible bridge
Date: Fri, 23 Mar 2007 14:38:36 +0100
Message-ID: <20070323133836.GH3980@xi.wantstofly.org>
References: <20070322205255.GG13869@mail.xprtsol.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Bin He <bhe@xprtsol.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:39607 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422927AbXCWOEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 10:04:44 -0400
Content-Disposition: inline
In-Reply-To: <20070322205255.GG13869@mail.xprtsol.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 22, 2007 at 03:52:55PM -0500, Bin He wrote:

> Dear sir,

Hi,


> I found your email address from kernel bridge source codes. I would
> appreciate if you could look into my question a little bit.

The netdev@ mailing list is a better forum to ask such questions,
I've CC'ed this email there.


> I have an invisible bridge (br0) which contains eth0 and eth1. None
> of them have an IP address because I want to it to be transparent to
> the existing network. So there is no entries in kernel routing table.

If you have an IP address assigned to br0, your kernel will likely have
(at least) one entry in its routing table even if you didn't put any
routes in there yourself.


> The problem is how does it handle the routing, i.e., which eth
> interface will a packet be sent to?

(The decision which bridge sub-device to send a packet to isn't
called 'routing', as it doesn't involve an IP routing decision --
that decision has already been made at that point.)


> For example, I can create a packet and bind it to a device by
> SO_BINDTODEVICE socket option. I did some tests and found:
> 1) if the socket is bound to eth0 or eth1, the packet cannot be sent out.
> 2) if the socket is bound to br0, it seems that the packet is only
> sent out to eth0.

Check out your system's ARP table (run /sbin/arp) and your br0
bridge's MAC address table (run 'brctl showmacs br0' or something
like that.)

When your machine wants to communicate with a remote IP address, it
first sends an ARP packet to figure out what the ethernet address is
that corresponds to that remote IP address.

When your machine then sends an IP packet on the br0 interface to that
ethernet address, the bridge code checks the MAC address table to find
out whether to send it to eth0 or eth1 (if the MAC address is a known
MAC address) or to both (if we have never seen the MAC address before
or if it has timed out.)


> So is there a way to send out a packet on a particular device?

I'm not sure exactly what you are trying to do?
