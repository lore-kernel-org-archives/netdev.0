From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Subject: Re: [net-next-2.6 PATCH][be2net] Code changes to handle dev pvt
	ioctl
Date: Tue, 26 May 2009 16:18:53 +0530
Message-ID: <20090526104852.GA27698@serverengines.com>
References: <20090524053149.GA17527@serverengines.com> <20090525.003422.117077559.davem@davemloft.net>
Reply-To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:54753 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750897AbZEZKrn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 06:47:43 -0400
Content-Disposition: inline
In-Reply-To: <20090525.003422.117077559.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The private ioctl is being implemented primarily to meet the following OEM
requirements.

1.  A mechanism to retrieve the last post mortem dump of the firmware and h/w
state.
2.  Fine tune port equalization parameters of the physical ports.
3.  A mechanism to flash the firmware at any point (not just at driver load
time).

A private ioctl seemed to be the only available mechanism to accomplish all
these.  Also we noticed that couple of other NIC drivers had implemented
private ioctls. If you feel there are better ways to do this, please let me
know.

- Sarvesh

On 25/05/09 00:34 -0700, David Miller wrote:
> From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
> Date: Sun, 24 May 2009 11:01:58 +0530
> 
> > Resubmitting patch for net-next tree to handle SIOCDEVPRIVATE ioctl. Also
> > have incorporated comments given by Ben Hutchings.
> > 
> > Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>
> 
> So what kind of diagnostic commands do userlevel tools need
> this for?
> 
> If they fall into useful generic categories, I'd rather you add new
> ethtool commands for doing them, one for each diagnostic command.
> For all I know, we might even have such things already if this is
> for self-test, firmware upload/download, or similar.
> 
> Device private ioctls are heavily undesirable, because every driver
> implements different ones, and thus the experience for users and tool
> writers is completely inconsistent.
> 
> Until I know more about what this is going to be used for I am
> rejecting this patch.
> 
> I really don't like any of the changes I've seen submitted recently
> for the be2net driver, to be honest with you. :-/
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
