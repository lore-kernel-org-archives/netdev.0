From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH] bridge: Enable configuration of ageing interval for
 bridges and switch devices.
Date: Thu, 20 Aug 2015 08:30:19 +0200
Message-ID: <20150820063019.GA11515@unicorn.suse.cz>
References: <77EF4405DD4BB54AACCE7DB593DF6A9A9E1E8D@SJEXCHMB14.corp.ad.broadcom.com>
 <alpine.DEB.2.02.1508172358470.13562@rocker1.rocker.net>
 <77EF4405DD4BB54AACCE7DB593DF6A9A9E2BFE@SJEXCHMB14.corp.ad.broadcom.com>
 <CAE4R7bD-r1=xo2+HMKdPpf7A3Vd7SXYsxm=xC0oNANtuG+F4iw@mail.gmail.com>
 <91179B48C1F7014B86296413F181061E3D56B6E1@FMSMSX114.amr.corp.intel.com>
 <77EF4405DD4BB54AACCE7DB593DF6A9A9E3076@SJEXCHMB14.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Wilson, Daniel G" <daniel.wilson@intel.com>,
	Scott Feldman <sfeldma@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Premkumar Jonnala <pjonnala@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:60646 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750981AbbHTGaV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Aug 2015 02:30:21 -0400
Content-Disposition: inline
In-Reply-To: <77EF4405DD4BB54AACCE7DB593DF6A9A9E3076@SJEXCHMB14.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 20, 2015 at 05:08:51AM +0000, Premkumar Jonnala wrote:
> > From: Wilson, Daniel G [mailto:daniel.wilson@intel.com]
> > >
> > > Can you extend bridge command to allow setting/getting these bridge attrs?
> > > Looks like you construct a RTM_NEWLINK IFLA_INFO_DATA msg.  No changes
> > > needed to the kernel.
> > >
> > > bridge link set dev br0 ageing_time 1000
> > >
> > >  --or--
> > >
> > > ip link set dev br0 type bridge ageing_time 1000
> > 
> > Being able to set these attributes via both bridge and ip would be great.
> > 
> IMHO, we should choose only one command.  Otherwise, we'd have to
> spend effort in trying to keep both the commands in sync.

As long as they are using the same netlink interface, I don't think it's
a serious problem. After all, there will be also other tools (wicked,
perhaps systemd-networkd) setting it directly via netlink rather than
calling either ip or bridge.

> My vote would be for the bridge command - since the options/parameters
> are related to bridges.  If there is no objection, I'll move all the
> bridge options from 'ip link' command to 'bridge' command.

This would break existing scripts using ip to set the parameter. Is the
possibility to use any of the two really that bad?

                                                         Michal Kubecek
