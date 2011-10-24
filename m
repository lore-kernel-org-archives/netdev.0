From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFD] Network configuration data in sysfs
Date: Mon, 24 Oct 2011 22:17:01 +0200
Message-ID: <20111024221701.0775d227@s6510.linuxnetplumber.net>
References: <20111023233558.GA23264@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Alexey Gladkov <gladkov.alexey@gmail.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45670 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754446Ab1JXURJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Oct 2011 16:17:09 -0400
In-Reply-To: <20111023233558.GA23264@shutemov.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 24 Oct 2011 02:35:58 +0300
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> Hi,
> 
> Currently there's no way to set or inspect network configuration (protocol
> addresses, routes, etc.) through sysfs. Yes, we have netlink interface for
> this, but sysfs has advantage:
> 
> - change or inspect network configuration using standard unix utilities
>   (echo, cat, etc.). It's useful at least in restricted environment where
>   no special utilities available -- initrd or stripped down busybox.

Last I checked busybox had a stripped down version of iproute arealdy.

> - transparent udev support. It would be nice to get this information to
>   udev.
> 
> Is there something fundamental preventing us to have sysfs interface for
> network configuration?
> 

Sysfs does not support the concept of transactions. Many network operations
require setting multiple values at a time; which is why a message interface
like netlink works much better.
