From: Eugene Surovegin <ebs@ebshome.net>
Subject: Re: [PATCH] net: EMAC: Fix problem with mtu > 4080 on non TAH
	equipped 4xx PPC's
Date: Tue, 15 Jan 2008 09:32:02 -0800
Message-ID: <20080115173202.GA1268@gate.ebshome.net>
References: <1200400809-19720-1-git-send-email-sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.ebshome.net ([208.106.21.240]:48548 "EHLO gate.ebshome.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750851AbYAORcF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2008 12:32:05 -0500
Content-Disposition: inline
In-Reply-To: <1200400809-19720-1-git-send-email-sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 15, 2008 at 01:40:09PM +0100, Stefan Roese wrote:
> Currently, all non TAH equipped 4xx PPC's call emac_start_xmit() upon
> xmit. This routine doesn't check if the frame length exceeds the max.
> MAL buffer size.
> 
> This patch now changes the driver to call emac_start_xmit_sg() on all
> platforms and not only the TAH equipped ones (440GX). This enables an
> MTU of 9000 instead 4080.
> 
> Tested on Kilauea (405EX) with gbit link -> jumbo frames enabled.
> 
> Signed-off-by: Stefan Roese <sr@denx.de>
> ---
> Eugene & Ben, do you see any problems with this patch? If not, then I'll
> send another version for the newemac driver too.

Hmm, so why not make GigE support a condition to hook SG version of 
xmit then? I don't like when you change behaviour for chips where it 
perefectly legal not to do this check because you cannot change MTU 
anyways.

-- 
Eugene

