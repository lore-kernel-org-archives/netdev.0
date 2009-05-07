From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] igb: Implement reading of reg RQDPC (Receive Queue
 Drop Packet Count)
Date: Thu, 7 May 2009 12:24:28 -0700
Message-ID: <20090507122428.0a8e3309@nehalam>
References: <1241703346.18487.22.camel@localhost.localdomain>
	<1241703431.18487.25.camel@localhost.localdomain>
	<EA929A9653AAE14F841771FB1DE5A1365F7744D662@rrsmsx501.amr.corp.intel.com>
	<Pine.LNX.4.64.0905072105480.13735@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Williams, Mitch A" <mitch.a.williams@intel.com>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50239 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751308AbZEGTYe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2009 15:24:34 -0400
In-Reply-To: <Pine.LNX.4.64.0905072105480.13735@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 7 May 2009 21:19:35 +0200 (CEST)
Jesper Dangaard Brouer <hawk@diku.dk> wrote:

> 
> On Thu, 7 May 2009, Williams, Mitch A wrote:
> 
> >> Implement reading the per queue drop stats register
> >> RQDPC (Receive Queue Drop Packet Count).  It counts the number of
> >> packets dropped by a queue due to lack of descriptors available.
> >>
> >> Notice RQDPC (Receive Queue Drop Packet Count) stats only gets
> >> incremented, if the DROP_EN bit it set (in the SRRCTL register
> >> for that queue). If DROP_EN bit is NOT set, then the some what
> >> equivalent count is stored in RNBC (not per queue basis).
> >>
> >> The RQDPC register is only 12 bit, thus the precision might
> >> suffer due to overrun in-between the watchdog polling interval.
> >
> > NAK.  82575 doesn't have RQDPC registers.  You need to check
> > which part you're running on before you read those registers.
> 
> Strange, I though the RQDPC register were compatible with the 82575 
> registers, as the 82576 datasheet states:
> 
> Quote 82576 DS:
>    Note: In order to keep compatibility with the 82575, for queues 0-3,
>    these registers are aliased to addresses 0x2830, 0x2930, 0x2A30 & 0x2B30
>    respectively.
> 
> And I do take care of reading the aliased adresses in the RQDPC define 
> statement for queues 0-3.
> 
> Well, I unfortunatly done have a 82575 based NIC anymore (as my prototype 
> NIC from Hotlava Systems Inc. just died).  And I don't have the 82575 
> datasheet, it does not seem to be available!?
> 
> Any chance I could get the 82575 register datasheet?
> 
> 
> > Other than that, this looks OK to me.
> 
> That sounds good :-)
> 
> ps. It will be monday or tuesday before I have time to repost the 
> patchset.
> 
> Cheers,
>    Jesper Brouer
> 


I'll test the patch, but what would happen if the registers were not
there?
