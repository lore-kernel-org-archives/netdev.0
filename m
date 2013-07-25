From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/3] tuntap: allow changing ethtool speed (v2)
Date: Wed, 24 Jul 2013 17:17:50 -0700
Message-ID: <20130724171750.112cf0df@nehalam.linuxnetplumber.net>
References: <20130724161156.4a8cf02b@nehalam.linuxnetplumber.net>
	<1374709250.1732.40.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Helmut Grohne <h.grohne@cygnusnetworks.de>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36132 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753740Ab3GYARx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 20:17:53 -0400
Received: by mail-pa0-f44.google.com with SMTP id jh10so1295000pab.17
        for <netdev@vger.kernel.org>; Wed, 24 Jul 2013 17:17:53 -0700 (PDT)
In-Reply-To: <1374709250.1732.40.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Jul 2013 00:40:50 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Wed, 2013-07-24 at 16:11 -0700, Stephen Hemminger wrote:
> > The data reported by the ethtool interface for tun/tap devices is
> > artificial. The default speed is 10Mbit. Virtual interfaces are often
> > faster than this nowadays, so the observed bandwidth may exceed the
> > available bandwidth. This patch allows an administrator to change the
> > available bandwidth as reported by ethtool.
> > 
> > Signed-off-by: Helmut Grohne <h.grohne@cygnusnetworks.de>
> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> > 
> > ---
> > v2 - allow setting duplex as well, fix patch formatting
> 
> It's logically full duplex so this doesn't make sense to me.
> 
> >      ignore other settings in set
> [...]
> 
> No, please never do that in ethtool_ops::set_settings.  Setting
> unsupported values is an error.

Almost every hardware driver out there allows mucking with settings
that it doesn't care about (like transceiver and port). Why be picky now?
