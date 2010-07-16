From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] Enhance dev_ioctl to return <hwaddr>:<if_name::if_index>
  mapping
Date: Fri, 16 Jul 2010 11:31:13 -0700
Message-ID: <20100716113113.1e2b51c7@nehalam>
References: <AANLkTinxLy2noL0GcZyVtMsEndxseCr6kkxuvyBNIfHr@mail.gmail.com>
	<1279300205.2097.9.camel@achroite.uk.solarflarecom.com>
	<20100716110407.316eb8f1@s6510>
	<D3F292ADF945FB49B35E96C94C2061B90C55C202@nsmail.netscout.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Ben Hutchings" <bhutchings@solarflare.com>,
	"Chetan Loke" <chetanloke@gmail.com>, <netdev@vger.kernel.org>
To: "Loke, Chetan" <Chetan.Loke@netscout.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57808 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758773Ab0GPSbQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jul 2010 14:31:16 -0400
In-Reply-To: <D3F292ADF945FB49B35E96C94C2061B90C55C202@nsmail.netscout.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 Jul 2010 14:12:24 -0400
"Loke, Chetan" <Chetan.Loke@netscout.com> wrote:

> > -----Original Message-----
> > From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> > Sent: July 16, 2010 2:04 PM
>  
> > The additional API is not needed. It is trivial to find address for
> > device and do reverse mapping. Either with ioctl's 
> Sorry, I might have missed it. But which ioctl would that be?

Simple way:
   Use SIOCGIFCONF to get list of interfaces
   Use SIOCGIFHWADDR to read device addresss

If you want to handle the case where device address is set
by bonding or other protocols, use ETHTOOL_GPERMADDR to read
the original ethernet address.

> > or /sys/class/net/XXX/addr
> So, is reading /sys/ nodes preferred over get-calls?

No difference
