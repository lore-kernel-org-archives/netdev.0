From: Greg Rose <gregory.v.rose@intel.com>
Subject: Re: RFC: rtnetlink problems with Cisco enic and VFs
Date: Tue, 22 Apr 2014 17:04:38 -0700
Message-ID: <20140422170438.00006b45@unknown>
References: <20140422141425.127dabd3c63482a6a655469e@redhat.com>
	<1398189799.7767.80.camel@deadeye.wl.decadent.org.uk>
	<20140422.141200.1878796491205301689.davem@davemloft.net>
	<20140423092606.c73425b64d127b8f94469fcb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <ben@decadent.org.uk>,
	<netdev@vger.kernel.org>, <benve@cisco.com>, <ssujith@cisco.com>,
	<govindarajulu90@gmail.com>, <neepatel@cisco.com>,
	<nistrive@cisco.com>
To: David Gibson <dgibson@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:43669 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750781AbaDWAEo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2014 20:04:44 -0400
In-Reply-To: <20140423092606.c73425b64d127b8f94469fcb@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Apr 2014 09:26:06 +1000
David Gibson <dgibson@redhat.com> wrote:

> On Tue, 22 Apr 2014 14:12:00 -0400 (EDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Ben Hutchings <ben@decadent.org.uk>
> > Date: Tue, 22 Apr 2014 19:03:19 +0100
> > 
> > > On Tue, 2014-04-22 at 14:14 +1000, David Gibson wrote:
> > >> I believe I've found a problem with netlink handling which can be
> > >> triggered on Cisco enic devices with a large number (30-40) of
> > >> virtual functions.  I believe this is the cause of a real
> > >> customer problem we've seen.
> > >> 
> > >>  * When requesting a list of interfaces with RTM_GETLINK, enic
> > >> devices (and currently, _only_ enic devices) report IFLA_VF_PORTS
> > >>    information 
> > >> 
> > >>  * IFLA_VF_PORTS information has at least 90 bytes ber virtual
> > >> function
> > >> 
> > >>  * Unlike IFLA_VFINFO_LIST, the ports information is always
> > >> reported, regardless of the setting of the IFLA_EXT_MASK
> > >> parameter
> > > [...]
> > > 
> > > So I think you should make reporting of IFLA_VF_PORTS dependent
> > > on the same flag as IFLA_VFINFO_LIST.
> > 
> > I think that's what we'll have to do.
> 
> Ok, makes logical sense.
> 
> But does anyone know what tools make use of the IFLA_VF_PORTS
> information?  Do they set the IFLA_EXT_MASK already?
> 

So far as I know only the IP route tool 'ip link' sets that.  In fact,
that's the reason I had to add it some number of years and months ago
was because there were tools that didn't expect to get all the
additional VF info and those tools were getting borked by all the
additional goo sent up for VFs.

Beyond that who knows what anyone's been up to with other tools in
other places?

- Greg
