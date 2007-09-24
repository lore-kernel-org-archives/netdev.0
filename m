From: jamal <hadi@cyberus.ca>
Subject: RE: [PATCH 1/4] [NET_SCHED] explict hold dev tx lock
Date: Mon, 24 Sep 2007 18:51:38 -0400
Message-ID: <1190674298.4264.24.camel@localhost>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	 <20070916.161748.48388692.davem@davemloft.net>
	 <1189988958.4230.55.camel@localhost>  <1190569987.4256.52.camel@localhost>
	 <1190570205.4256.56.camel@localhost>
	 <D5C1322C3E673F459512FB59E0DDC32903A51122@orsmsx414.amr.corp.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, kaber@trash.net,
	shemminger@linux-foundation.org, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, rick.jones2@hp.com, xma@us.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	mcarlson@broadcom.com, jeff@garzik.org, mchan@broadcom.com,
	general@lists.openfabrics.org, kumarkr@linux.ibm.com,
	tgraf@suug.ch, randy.dunlap@oracle.com, sri@us.ibm.com
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.238]:40795 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754960AbXIXWvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2007 18:51:44 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1339916wxd
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2007 15:51:43 -0700 (PDT)
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32903A51122@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-24-09 at 12:12 -0700, Waskiewicz Jr, Peter P wrote:

> Hi Jamal,
> 	I've been (slowly) working on resurrecting the original design
> of my multiqueue patches to address this exact issue of the queue_lock
> being a hot item.  I added a queue_lock to each queue in the subqueue
> struct, and in the enqueue and dequeue, just lock that queue instead of
> the global device queue_lock.  The only two issues to overcome are the
> QDISC_RUNNING state flag, since that also serializes entry into the
> qdisc_restart() function, and the qdisc statistics maintenance, which
> needs to be serialized.  Do you think this work along with your patch
> will benefit from one another? 

The one thing that seems obvious is to use dev->hard_prep_xmit() in the
patches i posted to select the xmit ring. You should be able to do
figure out the txmit ring without holding any lock. 

I lost track of how/where things went since the last discussion; so i
need to wrap my mind around it to make sensisble suggestions - I know
the core patches are in the kernel but havent paid attention to details
and if you look at my second patch youd see a comment in
dev_batch_xmit() which says i need to scrutinize multiqueue more. 

cheers,
jamal

