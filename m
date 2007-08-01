From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Lksctp-developers] [PATCH] SCTP: drop SACK if ctsn is not less than the next tsn of assoc
Date: Wed, 1 Aug 2007 07:19:40 -0400
Message-ID: <20070801111939.GA7757@hmsreliant.homelinux.net>
References: <18087.57737.908842.337891@zeus.sw.starentnetworks.com> <46AEBE2B.1060702@cn.fujitsu.com> <20070731113709.GA28333@hmsreliant.homelinux.net> <1185902894.8234.5.camel@localhost.localdomain> <46AFDC97.6080909@cn.fujitsu.com> <5BCC24EA-FACD-4B5D-BD1C-2DB11DEDB46D@lurchi.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Yongjun <yjwei@cn.fujitsu.com>,
	Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
To: Michael Tuexen <Michael.Tuexen@lurchi.franken.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4555 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753687AbXHALU0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Aug 2007 07:20:26 -0400
Content-Disposition: inline
In-Reply-To: <5BCC24EA-FACD-4B5D-BD1C-2DB11DEDB46D@lurchi.franken.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 01, 2007 at 11:01:21AM +0200, Michael Tuexen wrote:
> Hi Wei,
> 
> see my comments in-line.
> 
> Best regards
> Michael
> 
><snip >
> >(*1) At this point ctsn_ack_point=0,next_tsn=2, ctsn=1, SACK is  
> >accept.
> >After accept SACK, ctsn_ack_point=1.
> >(*2) At this point ctsn_ack_point=1,next_tsn=6, ctsn=5,TSN_lt(ctsn,
> >ctsn_ack_point) is ture, so accept SACK, and then ctsn_ack_point=5
> >(*3) At this point SACK is a dup SACK, ctsn_ack_point=5,next_tsn=6,
> >ctsn=1000,TSN_lt(ctsn, ctsn_ack_point) is ture, so accept SACK, and  
> >then
> >ctsn_ack_point=1000
> I would not consider it a duplicate SACK. RFC 4460, section 2.37.2 says
> that an implementation SHOULD abort the association when receiving a
> SACK acknowledging unsent data. So I would suggest to send an ABORT  
> chunk.

+1.  I didn't notice the ctsn value before.  We can't safely accept that a peer
pre-acks data we haven't sent.  Too many security holes.  

Neil



-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@tuxdriver.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/
