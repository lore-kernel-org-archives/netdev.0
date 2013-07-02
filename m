From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.34] datapath: Add basic MPLS support to kernel
Date: Tue, 2 Jul 2013 13:16:28 +0900
Message-ID: <20130702041628.GD14567@verge.net.au>
References: <1372234717-8735-1-git-send-email-horms@verge.net.au>
 <CAEP_g=-uMQuwK7=35XG8xrToFDoe8HS8yBK51tSWOipS0FdYtA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jarno Rajahalme <jarno.rajahalme@nsn.com>,
	Joe Stringer <joe@wand.net.nz>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:60660 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714Ab3GBEQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 00:16:31 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=-uMQuwK7=35XG8xrToFDoe8HS8yBK51tSWOipS0FdYtA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 01, 2013 at 04:42:46PM -0700, Jesse Gross wrote:
> On Wed, Jun 26, 2013 at 1:18 AM, Simon Horman <horms@verge.net.au> wrote:
> > Allow datapath to recognize and extract MPLS labels into flow keys
> > and execute actions which push, pop, and set labels on packets.
> >
> > Based heavily on work by Leo Alterman, Ravi K, Isaku Yamahata and Joe Stringer.
> >
> > Cc: Ravi K <rkerur@gmail.com>
> > Cc: Leo Alterman <lalterman@nicira.com>
> > Cc: Isaku Yamahata <yamahata@valinux.co.jp>
> > Cc: Joe Stringer <joe@wand.net.nz>
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> Simon, have you thought any more about the header ordering issues? I
> don't think we've reached a conclusion at this point.

I believe that you then raised the issue of QinQ, which somehow
I failed to respond to, I apologise for that.

In particular, my understanding is that you are concerned the code will
miss-calculate the end of L2 headers in the presence of multiple VLAN tags.
Thus resulting in an MPLS push action inserting an MPLS LSE after the first
rather than the last VLAN tag. And that would likely change if QinQ support
was added to Open vSwtich.

I wonder if a good way forwards is to enhance the calculation
of the end of L2 headers (mac_len) and the beginning of L3 headers
(network_header) in ovs_flow_extract() such that it takes into
account the presence of more than one VLAN tag.
