From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: Ethernet-over-UDP virtual network interface
Date: Thu, 8 Mar 2012 11:11:38 -0500
Message-ID: <20120308161138.GB23774@kvack.org>
References: <CAKLmikOBPB7rTZu2EfK26=3AhOQUR8xg8n4ySUKRMFmBkC1J3g@mail.gmail.com> <20120304170101.GH21526@kvack.org> <CAKLmikOVydmSJEBWwDc=Jv4XPMi3dsS+Pn9=BP_bBePD0L7K8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Nejc Skoberne <nejc@skoberne.net>,
	Jernej Kos <kostko@unimatrix-one.org>, gw.2012@tnode.com
To: Mitar <mmitar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:45667 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757980Ab2CHQLj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2012 11:11:39 -0500
Content-Disposition: inline
In-Reply-To: <CAKLmikOVydmSJEBWwDc=Jv4XPMi3dsS+Pn9=BP_bBePD0L7K8A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 06, 2012 at 12:58:44AM +0100, Mitar wrote:
> I would like something state-less. I see L2TPv3 has support for

How stateless?

> unmanaged tunnels, but they still require tunnel id and session id
> what (if I assume that they have to be unique) makes it useless for
> our case. We have (if I simplify) a star-shaped topology with a
> central server in the middle. To the central server WiFi nodes
> (hundreds of them) connect. But we do not really want to require from
> a central server to know each WiFi node and prepare its tunnel
> endpoint for each node. We would just like that there would be virtual
> interface and UDP port and any packet send to the UDP port would be
> decapsulated and output through that virtual interface. The only thing
> which we would have to make sure is that each WiFi node has a virtual
> interface with unique MAC address.

L2TP is commonly used for star topology deployments, but with more 
flexibility.  The typical scenario is to use LACs (L2TP Access 
Concentrators) on the edge of the network to tunnel incoming sessions 
from clients to LNSes (L2TP Network servers) that actually perform the 
routing for the network.  There is some state involved, but tunnels can 
be configured without a password, effectively making the addition of new
LACs requiring no manually configured state on the LNS.  The Babylon PPP 
stack that I added L2TP and PPPoE support for is able to perform tunnel 
switching on incoming PPPoE or L2TP sessions.  Sessions can be directed to 
different LNSes based on the username an incoming session authenticates 
as.  It only supports L2TPv2 at present, though, but adding L2TPv3 wouldn't 
be too hard.

		-ben
-- 
"Thought is the essence of where you are now."
