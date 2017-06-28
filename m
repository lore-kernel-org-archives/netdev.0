From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 1/3] net: ethtool: add support for forward
 error correction modes
Date: Tue, 27 Jun 2017 23:41:10 -0700
Message-ID: <20170627234110.0c6fb87f@cakuba.netronome.com>
References: <1498331985-8525-1-git-send-email-roopa@cumulusnetworks.com>
        <1498331985-8525-2-git-send-email-roopa@cumulusnetworks.com>
        <20170627032239.05cdc462@cakuba.netronome.com>
        <20170628062734.mhtvmnpviskat47k@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>, davem@davemloft.net,
        linville@tuxdriver.com, netdev@vger.kernel.org,
        vidya.chowdary@gmail.com, olson@cumulusnetworks.com,
        leedom@chelsio.com, manojmalviya@chelsio.com, santosh@chelsio.com,
        yuval.mintz@qlogic.com, odedw@mellanox.com, ariela@mellanox.com,
        galp@mellanox.com, jeffrey.t.kirsher@intel.com
To: Dustin Byford <dustin@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:60987 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751043AbdF1GlU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Jun 2017 02:41:20 -0400
In-Reply-To: <20170628062734.mhtvmnpviskat47k@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Jun 2017 23:27:34 -0700, Dustin Byford wrote:
> On Tue Jun 27 03:22, Jakub Kicinski wrote:
> > On Sat, 24 Jun 2017 12:19:43 -0700, Roopa Prabhu wrote:  
> > > Encoding: Types of encoding
> > > Off    :  Turning off any encoding
> > > RS     :  enforcing RS-FEC encoding on supported speeds
> > > BaseR  :  enforcing Base R encoding on supported speeds
> > > Auto   :  IEEE defaults for the speed/medium combination  
> > 
> > Just to be sure - does auto mean autonegotiate as defined by IEEE or
> > some presets?  IIUC there is a notion of different length cables
> > defaulting to different strength of FEC in 25GE?  
> 
> In this context, "auto" doesn't mean autoneg.  Typically, if it's a
> copper (CR) link autoneg has taken care of the FEC settings.  If you're
> using sfecparam, you're probably dealing with optics where there is no
> real autoneg.
> 
> Here, the term "auto", in its simplest implementation, would mean the
> driver picks a preset based on the speed, cable (typically an SFF
> cable), and hardware capability.  "IEEE defaults" in the comment refers
> to a couple of tables you'll find in IEEE specs (sorry I can't dig them
> up at the moment) that suggest FEC modes based on speed, medium
> (CR/SR/LR) and perhaps length in the CR case.  So, yes, perhaps length
> is part of the calculation for the appropriate "auto" mode.  This is
> essentially why this patch set is important.  Drivers up until now can
> be thought of as implementing "auto".  Sometimes that matches the
> expectation of a link partner, especially if both sides support the
> "IEEE defaults", but it's somewhat common for there to be a mismatch.
> That can be because one side isn't using the "IEEE default" FEC mode for
> the speed/medium/length, but it can also be because the hardware doesn't
> support the most common FEC mode for a speed/medium/length.  We need a
> way to explicitly set the FEC mode.  But, the hope is that "auto" is a
> reasonable default.


Thanks for the explanation!
