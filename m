From: Vitalii Demianets <vitas@nppfactor.kiev.ua>
Subject: Re: [PATCH net-next V4 00/13] Add basic VLAN support to bridges
Date: Thu, 20 Dec 2012 12:08:13 +0200
Message-ID: <201212201208.14204.vitas@nppfactor.kiev.ua>
References: <1355939304-21804-1-git-send-email-vyasevic@redhat.com> <CAKTPYJTAB-oOW5UE9EbNxwA+XbhmJu1FLrvq_mU8B1Qi6trxeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	shemminger@vyatta.com, davem@davemloft.net, or.gerlitz@gmail.com,
	jhs@mojatatu.com, mst@redhat.com, erdnetdev@gmail.com,
	jiri@resnulli.us
To: Andrew Collins <bsderandrew@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.cyfra.ua ([62.80.160.182]:43370 "EHLO mx3.cyfra.ua"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750956Ab2LTK23 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2012 05:28:29 -0500
In-Reply-To: <CAKTPYJTAB-oOW5UE9EbNxwA+XbhmJu1FLrvq_mU8B1Qi6trxeA@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 20 December 2012 00:54:27 Andrew Collins wrote:
> On Wed, Dec 19, 2012 at 10:48 AM, Vlad Yasevich <vyasevic@redhat.com> wrote:
> > This series of patches provides an ability to add VLANs to the bridge
> > ports.  This is similar to what can be found in most switches.  The
> > bridge port may have any number of VLANs added to it including vlan 0
> > priority tagged traffic.  When vlans are added to the port, only traffic
> > tagged with particular vlan will forwarded over this port.  Additionally,
> > vlan ids are added to FDB entries and become part of the lookup.  This
> > way we correctly identify the FDB entry.
>
> This is likely well beyond the scope of this change, but I figured I'd
> throw out the question anyway.  This changeset looks to bring the
> Linux bridging code closer to the 802.1Q-2005 definition of a bridge,
> which is nice to see, I'm curious if this changeset also opens up the
> possibility of supporting MSTP in the future?  The big thing I see
> missing is per-VLAN port state, although I'm not very familiar with
> the current STP/bridge interactions.  Has anyone put any thought into
> what other necessary bridge pieces might be missing for MSTP support?

I think, to be compatible with 802.1Q-2005 we need the following pieces:
1) Multiple FIDs (it is 802.1Q term for FDB) support. It means that kernel 
should support several independent FDBs on a single bridge. The 802.1Q-2005 
standard requires the number of supported FDBs to be no less than the number 
of different MSTIs the implementation supports;
2) VLAN-to-FDB mapping should be introduced;
3) Support of Multiple Spanning Tree Instances (MSTIs);
4) FDB-to-MSTI mapping should be introduced;
5) And finally, per-MST port states should be implemented.

> obviously something to handle the MSTP protocol itself would need to exist 
as well

Please look here: http://sourceforge.net/projects/mstpd/
