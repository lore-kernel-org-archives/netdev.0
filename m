From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] geneve: restore vlan bits in xmit path
Date: Thu, 17 Sep 2015 16:15:46 -0400
Message-ID: <20150917201545.GF25806@tuxdriver.com>
References: <1442510338-10180-1-git-send-email-linville@tuxdriver.com>
 <CALnjE+r9A0bUmF-ZEvUdhop2kD7VGQYpn0PKG23cCU9qcrUrVQ@mail.gmail.com>
 <20150917192534.GE25806@tuxdriver.com>
 <CAEP_g=8v__N59dKe1wUfgHDjgrvGzXWN4AJ=ifeuxxn_FNmDQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pravin Shelar <pshelar@nicira.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58523 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752027AbbIQUaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 16:30:14 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=8v__N59dKe1wUfgHDjgrvGzXWN4AJ=ifeuxxn_FNmDQQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 17, 2015 at 12:48:56PM -0700, Jesse Gross wrote:
> On Thu, Sep 17, 2015 at 12:25 PM, John W. Linville
> <linville@tuxdriver.com> wrote:
> > On Thu, Sep 17, 2015 at 11:45:58AM -0700, Pravin Shelar wrote:
> >> On Thu, Sep 17, 2015 at 10:18 AM, John W. Linville
> >> <linville@tuxdriver.com> wrote:
> >> > These seem to have been accidentally dropped in commit 371bd1061d29
> >> > ("geneve: Consolidate Geneve functionality in single module.").
> >> >
> >> Geneve should not export vxlan feature. So that it never sees vxlan
> >> tagged packets. Can you turn off the vlan feature?
> >
> > I'm not sure I understand...?  This is vlan, not vxlan.
> 
> I think he just mean vlan. If you remove the line where
> dev->vlan_features are set then the core stack will handle this and we
> don't need to do anything special here.

Is that preferrable to this patch?  Tunneling vlan-tagged frames
seems weird, but I would hate to disallow it if some crazy person
wanted to do that...

I guess the other way would slightly improve performance, and this
could be added back later.  What about the VLAN-related bits in
dev->features and ->hw_features?  Should they go as well?

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
