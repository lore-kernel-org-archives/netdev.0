From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Is 802.3ad mode in bonding useful ?
Date: Fri, 29 Apr 2011 06:43:42 -0400
Message-ID: <20110429104342.GA22387@hmsreliant.think-freely.org>
References: <4DB9185E.4050103@gmail.com>
 <20110428122102.GB4165@hmsreliant.think-freely.org>
 <4DBA2DDC.80502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: WeipingPan <panweiping3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50850 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753269Ab1D2Knx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 06:43:53 -0400
Content-Disposition: inline
In-Reply-To: <4DBA2DDC.80502@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 29, 2011 at 11:17:48AM +0800, WeipingPan wrote:
> On 04/28/2011 08:21 PM, Neil Horman wrote:
> >On Thu, Apr 28, 2011 at 03:33:50PM +0800, WeipingPan wrote:
> >>Hi, all,
> >>
> >>802.3ad mode in bonding implements 802.3ad standard.
> >>
> >>I am just wondering  802.3ad mode is useful,
> >>since  bonding has many modes like balance-rr, active-backup, etc.
> >>
> >Yes, of course its usefull.  For switches which support 802.3ad, this mode
> >allows for both peers to understand that the links in the bond are acting as an
> >aggregate, which makes it easier to prevent things like inadvertently looped
> >back frames, for which the other modes have to have all sorts of hacks to
> >prevent.
> What is looped back frames here ?
In this case they are frames that get received by the bond, which the bond
itself sent.  In modes where more than one slave is active, and in which the
switch has no additional knoweldge of the aggregate (e.g. round robin mode), the
bond can send a frame on one slave, which the switch may broadcast to all ports,
causing the frame just sent by the bond to then get received on another slave.

> I didn't see any special code to handle looped back frames in other
> modes in bonding,
> can you take an example ?
> 
See bond_handle_frame.

Neil

> thanks
> Weiping Pan
> 
> >Neil
> >
> 
> 
