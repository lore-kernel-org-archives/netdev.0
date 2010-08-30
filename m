From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [rfc] Merging the Open vSwitch datapath
Date: Mon, 30 Aug 2010 13:59:07 -0700
Message-ID: <20100830205907.GM30129@sequoia.sous-sol.org>
References: <20100830062755.GA22396@verge.net.au>
 <87k4n8ow1r.fsf@benpfaff.org>
 <43F901BD926A4E43B106BF17856F0755F63A08EE@orsmsx508.amr.corp.intel.com>
 <20100830183328.GI7629@nicira.com>
 <43F901BD926A4E43B106BF17856F0755F63A092B@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Pfaff <blp@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Chris Wright <chrisw@sous-sol.org>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Arnd Bergmann <arnd@arndb.de>,
	David Miller <davem@davemloft.net>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sous-sol.org ([216.99.217.87]:46818 "EHLO sequoia.sous-sol.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754528Ab0H3Vcc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Aug 2010 17:32:32 -0400
Content-Disposition: inline
In-Reply-To: <43F901BD926A4E43B106BF17856F0755F63A092B@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Rose, Gregory V (gregory.v.rose@intel.com) wrote:
> >From: Ben Pfaff [mailto:blp@nicira.com]
> >On Mon, Aug 30, 2010 at 11:26:17AM -0700, Rose, Gregory V wrote:
> >> I just want to put in a plug for the netlink interface.  For NICs with
> >> EVB we'll need it.
> >
> >Off-hand, the main reasons to use Netlink, instead of the existing
> >character device interface, are that Netlink is easier to extend and
> >that it should reduce or eliminate the 32-to-64 bit compat layer
> >currently in the Open vSwitch tree.

That, plus it's a typical way to do network configuration.  Esp. with
bi-directional communication.  So the userspace bit both listens to
netlink messages, like any of the routing daemons or lldpad or similar
do, and sends netlink messasges to update driver's flow table.

BTW, this kind of discussion was why Herbert felt strongly against
drivers/staging/.  He wanted to be sure the interfaces were well-defined
first.

> >Why will NICs with EVB require Netlink for the Open vSwitch interface?
> 
> As of now there are no existing ways to get switch configuration to a NIC without resorting to a customized interface such as a private IOCTL.  EVB is an emerging standard that I think would be desirable to support in the kernel.  As you mention netlink is easier to extend and I think it would be a great way to add support for NIC EVB in the kernel.  But even with a kernel interface there is still no user level tool.

Right, there's the netlink interface for VFINFO, and a short list I
compiled a while back of "requirements"

http://permalink.gmane.org/gmane.linux.network/158930

> >From what I can tell the Open vSwitch interface with its ability to set packet forwarding rules is also a good candidate for a user space tool to set rules for EVB capable NICs.  Seems like a natural extension to me.

Yup, but also consider that the NIC's switches will lag sw.  So likely
need a way to say what the thing is capable of so that rules that can't
be enforced in NIC hw are done in sw (or in external hw, ala 802.1Qbg).

thanks,
-chris
