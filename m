From: Tobias Jungel <tobias.jungel@bisdn.de>
Subject: Re: [PATCH] bridge: netlink: check vlan_default_pvid range
Date: Mon, 15 May 2017 16:38:25 +0200
Message-ID: <1494859105.25314.7.camel@bisdn.de>
References: <20170515110819.11847-1-tobias.jungel@bisdn.de>
         <20170515120120.GA13122@bistromath.localdomain>
         <1494854492.25314.5.camel@bisdn.de>
         <260c1889-288b-c4f5-53ad-81cf3db1c26c@cumulusnetworks.com>
         <54d47a4c-2bbc-ba5c-e147-73c2f48b3cc6@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.bisdn.de ([185.27.182.31]:45061 "EHLO mx.bisdn.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934481AbdEOOi2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 15 May 2017 10:38:28 -0400
In-Reply-To: <54d47a4c-2bbc-ba5c-e147-73c2f48b3cc6@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-05-15 at 16:31 +0300, Nikolay Aleksandrov wrote:
> On 5/15/17 4:29 PM, Nikolay Aleksandrov wrote:
> > On 5/15/17 4:21 PM, Tobias Jungel wrote:
> > > Thanks Sabrina and Nik.
> > > 
> > > On Mon, 2017-05-15 at 14:01 +0200, Sabrina Dubroca wrote:
> > > > Hi Tobias,
> > > > 
> > > > 2017-05-15, 13:08:19 +0200, Tobias Jungel wrote:
> > > > > Currently it is allowed to set the default pvid of a bridge
> > > > > to a
> > > > > value
> > > > > above VLAN_VID_MASK (0xfff). This patch checks the passed
> > > > > pvid and
> > > > > disables the pvid in case it is out of bounds.
> > > > 
> > > > Could we return an error (-EINVAL) to userspace
> > > > instead?  Silently
> > > > disabling the feature seems confusing to me.  This would
> > > > probably be
> > > > better in br_validate() (like the IFLA_BR_VLAN_PROTOCOL check),
> > > > since
> > > > there's already such a check when setting default_pvid from
> > > > sysfs (in
> > > > br_vlan_set_default_pvid()).
> > > 
> > > I will send a v2 that returns -EINVAL. br_validate seems to be
> > > the
> > > wrong place to me since it deals with the bridge ports.
> > > 
> > 
> > Could you elaborate ? br_validate should be called for all and is a
> > very good
> > suggestion.
> 
> I meant for the bridge newlink/changelink of course. :-)

Sorry had a wrong understanding of that function. Will come up with a
v3 later.

> 
> > 
> > > > 
> > > > > 
> > > > > Reproduce by calling:
> > > > > 
> > > > > [root@test ~]# ip l a type bridge
> > > > > [root@test ~]# ip l a type dummy
> > > > > [root@test ~]# ip l s bridge0 type bridge vlan_filtering 1
> > > > > [root@test ~]# ip l s bridge0 type bridge vlan_default_pvid
> > > > > 9999
> > > > > [root@test ~]# ip l s dummy0 master bridge0
> > > > > [root@test ~]# bridge vlan
> > > > > port    vlan ids
> > > > > bridge0     9999 PVID Egress Untagged
> > > > > 
> > > > > dummy0     9999 PVID Egress Untagged
> > > > 
> > > > You'll also need to add a Signed-off-by, and a Fixes tag would
> > > > be
> > > > nice.
> > > > 
> > > 
> > > Right, will add this as well.
> > > 
> > > > 
> > > > Thanks,
> > > > 
> 
> 
