From: Stefan Roese <sr@denx.de>
Subject: Re: [PATCH] net: EMAC: Fix problem with mtu > 4080 on non TAH  equipped 4xx PPC's
Date: Tue, 15 Jan 2008 20:46:01 +0100
Message-ID: <200801152046.01881.sr@denx.de>
References: <1200400809-19720-1-git-send-email-sr@denx.de> <20080115173202.GA1268@gate.ebshome.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Eugene Surovegin <ebs@ebshome.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.174]:52451 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750841AbYAOTqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 14:46:25 -0500
In-Reply-To: <20080115173202.GA1268@gate.ebshome.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 15 January 2008, Eugene Surovegin wrote:
> On Tue, Jan 15, 2008 at 01:40:09PM +0100, Stefan Roese wrote:
> > Currently, all non TAH equipped 4xx PPC's call emac_start_xmit() upon
> > xmit. This routine doesn't check if the frame length exceeds the max.
> > MAL buffer size.
> >
> > This patch now changes the driver to call emac_start_xmit_sg() on all
> > platforms and not only the TAH equipped ones (440GX). This enables an
> > MTU of 9000 instead 4080.
> >
> > Tested on Kilauea (405EX) with gbit link -> jumbo frames enabled.
> >
> > Signed-off-by: Stefan Roese <sr@denx.de>
> > ---
> > Eugene & Ben, do you see any problems with this patch? If not, then I'll
> > send another version for the newemac driver too.
>
> Hmm, so why not make GigE support a condition to hook SG version of
> xmit then? I don't like when you change behaviour for chips where it
> perefectly legal not to do this check because you cannot change MTU
> anyways.

OK. But how do we detect GigE support? Seems like GigE enabled devices have 
CONFIG_IBM_EMAC4 defined. If nobody objects I'll fix up another version 
tomorrow.

Thanks.

Best regards,
Stefan
