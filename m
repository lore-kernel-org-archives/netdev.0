From: Piotr =?iso-8859-2?q?Zi=EAcik?= <kosmo@semihalf.com>
Subject: Re: [PATCH 02/12] fs_enet: Add MPC5121 FEC support.
Date: Thu, 21 May 2009 10:34:39 +0200
Message-ID: <200905211034.39762.kosmo@semihalf.com>
References: <1241640919-4650-1-git-send-email-wd@denx.de> <200905141438.23348.kosmo@semihalf.com> <fa686aa40905140700k3ca28ac0m74c9c161ad538abc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Denk <wd@denx.de>, Scott Wood <scottwood@freescale.com>,
	John Rigby <jrigby@gmail.com>, linuxppc-dev@ozlabs.org,
	Detlev Zundel <dzu@denx.de>, netdev@vger.kernel.org,
	Kumar Gala <galak@kernel.crashing.org>,
	Becky Bruce <Becky.Bruce@freescale.com>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from semihalf.com ([206.130.101.55]:58165 "EHLO semihalf.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750757AbZEUIgD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2009 04:36:03 -0400
In-Reply-To: <fa686aa40905140700k3ca28ac0m74c9c161ad538abc@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thursday 14 May 2009 16:00:33 Grant Likely wrote:
> > MPC5121 support was added to drivers/net/fs_enet. MPC52xx uses
> > drivers/net/fec_mpc52xx.c. Do you think that creating one universal
> > driver from these two is now possible? You said that it should be easy,
> > however you also said that cache coherency issues makes this imposible.
>
> Not impossible.  Hard.

I thought a bit more about merging FEC drivers and I see one problem more.
Driver fs_enet works with FEC's with own DMA engine and fec_mpc52xx.c uses 
BestComm. Integration of these two drivers will need a DMA abstraction layer 
to keep everything clean. Unfortuanetly BestComm driver does not provide any 
abstraction - it only exports set of functions to deal with specific 
hardware: FEC and PATA.

More #ifdef's will be needed to remove linking with BestComm driver if kernel 
will be compiled without 52xx support and resulting code will not be much 
better than existing one. Especially that new DMA abstraction layer probably 
will be quite complex.

-- 
Best Regards.
Piotr Ziecik
