From: Roland Dreier <rdreier@cisco.com>
Subject: Re: RFC: on [ab]use of skb->cb by VLAN code
Date: Tue, 31 Jul 2007 10:50:15 -0700
Message-ID: <adair80o42w.fsf@cisco.com>
References: <1185847324.5162.31.camel@localhost>
	<20070730.190621.13770511.davem@davemloft.net>
	<46AEBADB.7030007@candelatech.com>
	<20070730.221847.74747100.davem@davemloft.net>
	<46AEC99E.10809@candelatech.com> <46AF69C7.1090504@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	kaber@trash.net, netdev@vger.kernel.org, mcarlson@broadcom.com
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3-in.cisco.com ([171.71.176.72]:18253 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763096AbXGaRue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 13:50:34 -0400
In-Reply-To: <46AF69C7.1090504@hp.com> (Rick Jones's message of "Tue, 31 Jul 2007 09:56:39 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > > Do we really need an 'unsigned int' for mac_len?  Maybe we could use
 > > a 16-bit counter here, and then use the other 16 bits for the VLAN bits?
 > 
 > Not knowing exactly if/how it interacts with that specific field I
 > will point-out that IPoIB in OFED 1.2 just took their MTU to 65520.
 > While that doesn't break the bitbank it does get rather close.

Leaving aside OFED releases, the IPoIB connected mode code in the
standard kernel also allows the MTU to go up to 65520.  And there's
nothing magic about that value -- we could easily do bigger packets.

However, this is irrelevant for two reasons: mac_len is the length of
the LL header, not the packet overall, *and* mac_len is already 16
bits as of commit 334a8132.

 - R.
