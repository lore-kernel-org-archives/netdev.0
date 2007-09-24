From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 1/4] [NET_SCHED] explict hold dev tx lock
Date: Mon, 24 Sep 2007 15:57:33 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903A51462@orsmsx414.amr.corp.intel.com>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com> <20070916.161748.48388692.davem@davemloft.net> <1189988958.4230.55.camel@localhost>  <1190569987.4256.52.camel@localhost> <1190570205.4256.56.camel@localhost> <D5C1322C3E673F459512FB59E0DDC32903A51122@orsmsx414.amr.corp.intel.com> <1190674298.4264.24.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, <krkumar2@in.ibm.com>,
	<johnpol@2ka.mipt.ru>, <herbert@gondor.apana.org.au>,
	<kaber@trash.net>, <shemminger@linux-foundation.org>,
	<jagana@us.ibm.com>, <Robert.Olsson@data.slu.se>,
	<rick.jones2@hp.com>, <xma@us.ibm.com>, <gaagaan@gmail.com>,
	<netdev@vger.kernel.org>, <rdreier@cisco.com>,
	<mcarlson@broadcom.com>, <jeff@garzik.org>, <mchan@broadcom.com>,
	<general@lists.openfabrics.org>, <kumarkr@linux.ibm.com>,
	<tgraf@suug.ch>, <randy.dunlap@oracle.com>, <sri@us.ibm.com>
To: <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:38291 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751413AbXIXW5b convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2007 18:57:31 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1190674298.4264.24.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The one thing that seems obvious is to use 
> dev->hard_prep_xmit() in the patches i posted to select the 
> xmit ring. You should be able to do figure out the txmit ring 
> without holding any lock. 

I've looked at that as a candidate to use.  The lock for enqueue would
be needed when actually placing the skb into the appropriate software
queue for the qdisc, so it'd be quick.

> I lost track of how/where things went since the last 
> discussion; so i need to wrap my mind around it to make 
> sensisble suggestions - I know the core patches are in the 
> kernel but havent paid attention to details and if you look 
> at my second patch youd see a comment in
> dev_batch_xmit() which says i need to scrutinize multiqueue more. 

No worries.  I'll try to get things together on my end and provide some
patches to add a per-queue lock.  In the meantime, I'll take a much
closer look at the batching code, since I've stopped looking at the
patches in-depth about a month ago.  :-(

Thanks,
-PJ Waskiewicz
