From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.62] datapath: Add basic MPLS support to kernel
Date: Sat, 28 Jun 2014 09:55:31 +0900
Message-ID: <20140628005531.GA4122@verge.net.au>
References: <1403611017-10965-1-git-send-email-horms@verge.net.au>
 <CAEP_g=9yYqKy-=aiTi3=3cZNOombBgkjHdzLdRzYVVKyJCHqcQ@mail.gmail.com>
 <20140625015149.GB14193@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Joe Stringer <joe@wand.net.nz>, Thomas Graf <tgraf@suug.ch>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:45056 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751496AbaF1Azo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 20:55:44 -0400
Content-Disposition: inline
In-Reply-To: <20140625015149.GB14193@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 25, 2014 at 10:51:52AM +0900, Simon Horman wrote:
> On Tue, Jun 24, 2014 at 04:24:37PM -0700, Jesse Gross wrote:
> > On Tue, Jun 24, 2014 at 4:56 AM, Simon Horman <horms@verge.net.au> wrote:
> > > Allow datapath to recognize and extract MPLS labels into flow keys
> > > and execute actions which push, pop, and set labels on packets.
> > >
> > > Based heavily on work by Leo Alterman, Ravi K, Isaku Yamahata and Joe Stringer.
> > >
> > > Cc: Ravi K <rkerur@gmail.com>
> > > Cc: Leo Alterman <lalterman@nicira.com>
> > > Cc: Isaku Yamahata <yamahata@valinux.co.jp>
> > > Cc: Joe Stringer <joe@wand.net.nz>
> > > Signed-off-by: Simon Horman <horms@verge.net.au>
> > 
> > Applied, thanks for all your work. Time to break out the champagne :)
> 
> Thanks, a moment for many to savour.
> 
> > That being said, I do have a couple of comments for follow up discussion:
> >  * I removed the addition of MPLS to key_attr_size. This is trying to
> > calculate the maximum key size and since MPLS will never show up in
> > conjunction with IPv6 (the current longest key) and isn't longer than
> > it, MPLS shouldn't increase the maximum size.
> 
> Thanks, sorry for messing that up.
> 
> >  * I think there is a potential for MPLS packets to be incorrectly
> > offloaded on kernels 3.12-3.15 when encapsulated inside a tunnel. This
> > is because it won't hit either the OVS GSO code or your enhanced MPLS
> > feature check. I don't want to lose GSO for tunnels on those kernels
> > but maybe there is a way to avoid this potential problem without too
> > much work.
> 
> I'll take a look into this unless someone else wants to jump in.
> 
> >  * Maybe you can refresh my memory - in the case of a push_mpls after
> > pop_vlan, why can't we do this check correctly for at least one level
> > of vlan? It seems like we could use the inner EtherType to tell
> > whether an additional vlan tag is present.
> 
> That seems likely. I'll do some analysis and get back to you.

I may be missing something but it seems to me that in
ovs_nla_copy_actions__() we have access to the outer EtherType and
VLAN TCI but not the inner EtherType.

It seems to me that the inner EtherType would need to be present
in the key for it to be available in ovs_nla_copy_actions__().
