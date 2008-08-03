From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG] NULL pointer dereference in skb_dequeue
Date: Sun, 3 Aug 2008 11:29:26 +0200
Message-ID: <20080803092926.GA2971@ami.dom.local>
References: <EA929A9653AAE14F841771FB1DE5A1365F1FBE8ADD@rrsmsx501.amr.corp.intel.com> <20080802133719.GB2970@ami.dom.local> <20080802162733.GA10059@ami.dom.local> <20080802.121815.167998262.davem@davemloft.net> <20080802201944.GA14983@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: emil.s.tantilov@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:45501 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752647AbYHCJ3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2008 05:29:14 -0400
Received: by nf-out-0910.google.com with SMTP id d3so590525nfc.21
        for <netdev@vger.kernel.org>; Sun, 03 Aug 2008 02:29:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080802201944.GA14983@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 02, 2008 at 10:19:44PM +0200, Jarek Poplawski wrote:
> On Sat, Aug 02, 2008 at 12:18:15PM -0700, David Miller wrote:
...
> > Jarek, we can't put the root lock back into the netdev_queue, it
> > breaks all of the RCU handling of qdisc_destroy() which is fundamental
> > for how all the multiqueue stuff works now.
> > 
> > See my other emails, it isn't even necessary anyways.
...
> Thanks for the explanations: BTW, I think, the qdisc_root_lock is a
> bit misleading name, if qdisc_lock is also used for taking root lock.
> Of course, this all makes sense, it simply needs more checking.

After some re-checking one more question: why do you think this
qdisc_root_lock() is safe as sch_tree_lock() (or anywhere else)? It
seems, eg. during deactivation it can get root_lock of qdisc_default,
and proceed with another qdisc?

Jarek P.
