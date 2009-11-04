From: Joe Perches <joe@perches.com>
Subject: RE: Subject: [PATCH 1/6] bna: Brocade 10Gb Ethernet device driver
Date: Tue, 03 Nov 2009 16:31:58 -0800
Message-ID: <1257294718.2892.23.camel@Joe-Laptop.home>
References: <200911010503.nA153Elp019063@blc-10-10.brocade.com>
	 <1257053039.1917.147.camel@Joe-Laptop.home>
	 <CBE1CC7A31453F4CA63C13EFCE6A0F6C05BAC64093@HQ-EXCH-7.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Adapter Linux Open SRC Team
	<adapter_linux_open_src_team@Brocade.COM>,
	Greg Kroah-Hartman <gregkh@suse.de>
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1217 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751326AbZKDAby (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2009 19:31:54 -0500
In-Reply-To: <CBE1CC7A31453F4CA63C13EFCE6A0F6C05BAC64093@HQ-EXCH-7.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-11-03 at 10:24 -0800, Rasesh Mody wrote:
> Joe,
> Thanks for your input. We are in the process addressing the comments that we are getting.

Hi Rasesh.

Thanks for bringing this out to netdev.

I think that with a few hours of cleanup, the code
would be more linux style conforming.  But right now,
it looks a bit odd with too many indirections.

> Can you please give examples or elaborate your comment? It would be really helpful.

OS dependent includes?  Most of them are senseless.

All of bfa_os_inc.h should go elsewhere or be dropped.
All of bna_os should go elsewhere or be dropped.

drop all bna_os_ prefixes

drop all bfa_os_ntohs, etc:

sed -r -i -e 's/\bbfa_os_(nh)to(nh)(sl)\b/\1to\2\3/g' *

Redefine true/false? why?

sed -r -i -e 's/\bbfa_boolean_t\b/bool/g' *
sed -r -i -e 's/\bBFA_TRUE\b/true/g' *
sed -r -i -e 's/\bBFA_FALSE\b/false/g' *

Don't suffix struct names with _s

sed -r -i -e 's/\bstruct\b\s+(\w+)\s+(\w+)_s/struct \1 \2/g' *

bfa_panic -> bfa_os_panic -> nothing

a laundry list like that...

I think it should go into staging for a few weeks, and then
it would be ready to be integrated into a mainline release.

cheers,  Joe 

