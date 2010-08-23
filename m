From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ethtool: allow non-netadmin to query settings
Date: Mon, 23 Aug 2010 14:40:41 -0700
Message-ID: <20100823144041.6a88c0ed@nehalam>
References: <20100823132418.7721b072@nehalam>
	<1282598678.2267.85.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55131 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754733Ab0HWVko (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Aug 2010 17:40:44 -0400
In-Reply-To: <1282598678.2267.85.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Aug 2010 22:24:38 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Mon, 2010-08-23 at 13:24 -0700, Stephen Hemminger wrote:
> > The SNMP daemon uses ethtool to determine the speed of
> > network interfaces. This fails on Debian (and probably elsewhere)
> > because for security SNMP daemon runs as non-root user (snmp).
> > 
> > Note: A similar patch was rejected previously because of a concern about
> > the possibility that on some hardware querying the ethtool settings
> > requires access to the PHY and could slow the machine down.  But the
> > security risk of requiring SNMP daemon (and related services)
> > to run as root far out weighs the risk of denial-of-service.
> [...]
> 
> Speed and duplex are now exposed through world-readable attributes in
> sysfs.  Currently this is implemented by calling the ethtool
> get_settings() operations but that could be improved on by adding speed
> and duplex fields to struct net_device or by allowing drivers to
> implement a cheaper operation that provides just this information.
> 

Changing daemon is possible, but changing every driver to do this
is not a practical option.
