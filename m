From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH net-next] bnx2x: Add Nic partitioning mode (57712
 devices)
Date: Thu, 6 Jan 2011 16:40:16 +0200
Message-ID: <1294324816.520.20302.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1290982177.6066.3.camel@lb-tlvb-dmitry>
 <20101129060114.GC29904@auslistsprd01.us.dell.com>
 <1291023192.9770.0.camel@lb-tlvb-eilong.il.broadcom.com>
 <20101206173534.GC13628@auslistsprd01.us.dell.com>
 <4CFD29BE.2060201@chelsio.com>
 <1291906166.21210.10.camel@lb-tlvb-eilong.il.broadcom.com>
 <20101217024509.GA5854@auslistsprd01.us.dell.com>
 <4D0BEE9A.5070505@chelsio.com>
 <20101219054953.GC5854@auslistsprd01.us.dell.com>
 <4D0FB233.9050501@chelsio.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Dimitris Michailidis" <dm@chelsio.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"narendra_k@dell.com" <narendra_k@dell.com>,
	"jordan_hargrave@dell.com" <jordan_hargrave@dell.com>
To: "Matt Domsch" <Matt_Domsch@dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1983 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752693Ab1AFOkb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 09:40:31 -0500
In-Reply-To: <4D0FB233.9050501@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-12-20 at 11:44 -0800, Dimitris Michailidis wrote:
> Matt Domsch wrote:
> >> You can have several interfaces with same device link and different dev_id. 
> >>  While the current driver doesn't do it you could also have several 
> >> interfaces with different device links but same dev_id (NPAR situation, 
> >> notice again that dev_ids are not per PCI function), or interfaces with 
> >> different device and dev_id, or even interfaces with same device and dev_id.
> > 
> > What is the scope of dev_id then?  It's not per PCI device like I
> > thought.
> 
> I don't think it could be that way because for these cards you can't 
> statically tell which ports are controlled by a PCI function.  So knowing 
> that an interface is say port 0 of a function would help little.
> 
> > It sounds like it's per card, but how can I know the card
> > boundary?
> 
> Yes, it's per card and covers the PFs and VFs of the card.
> 
> > If I have 2 cards driven by cxgb4 in the system, each with say 4
> > ports.  I could see a minimum of 8 PCI devices (fine), but the dev_id
> > values would be?  0,1,2,3; 0,1,2,3 ?
> 
> Correct.
> 
> > How can I tell that these are
> > two different cards, with two different sets of dev_id values, rather
> > than one card with 4 ports, 8 (NPAR or SR-IOV) interfaces, with each 2
> > interfaces mapping to the same port?
> 
> Doesn't the information in /sys/devices distinguish them?  For example, 
> something like
> 
> /sys/devices/pci0000:00/0000:00:07.0/0000:04:00.0/net/eth2/dev_id == 0
> /sys/devices/pci0000:00/0000:00:07.0/0000:04:00.1/net/eth3/dev_id == 0
> /sys/devices/pci0000:00/0000:00:07.0/0000:04:01.0/net/eth5/dev_id == 0
> /sys/devices/pci0000:00/0000:00:1c.0/0000:05:00.0/net/eth4/dev_id == 0
> 
> tells me there are two cards, one has eth4 on port 0, the other has eth2, 
> eth3, and eth5 on its port 0 with eth5 being on a VF.
> 
> > dev_id is not system-wide unique.  It's not even slot unique best as I
> > can tell.  If I had a PCI slot extender, with 2 PCI slots, and I put
> > two of the above cards in, I would see 0,1,2,3; 0,1,2,3.  To be fair,
> > my naming scheme doesn't really account for such an extender, though
> > currently it would go pci<slot>#<12345678>.
> 
> Can you give an example of what /sys/devices looks like in the case you're 
> considering?

Matt,

Happy New Year!

Does the dev_id approach suits your needs? Do you want to proceed in
that direction?

Thanks,
Eilon


