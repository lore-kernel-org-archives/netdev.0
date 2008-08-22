From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Fri, 22 Aug 2008 01:55:13 -0700 (PDT)
Message-ID: <20080822.015513.194132430.davem@davemloft.net>
References: <20080821185857.GA2665@ami.dom.local>
	<20080821222330.GE14521@gondor.apana.org.au>
	<20080822084931.GB2645@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	denys@visp.net.lb
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54593
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751958AbYHVIzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 04:55:15 -0400
In-Reply-To: <20080822084931.GB2645@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 22 Aug 2008 08:49:31 +0000

> On Fri, Aug 22, 2008 at 08:23:30AM +1000, Herbert Xu wrote:
> > On Thu, Aug 21, 2008 at 08:58:57PM +0200, Jarek Poplawski wrote:
> > >
> > > root qdisc with pointers copied to every dev_queue. At least I can't
> > > see nothing more in qdisc_create() and qdisc_graft(). So,
> > > qdisc_lookup() seems to be designed for the future (or to do this
> > > lookup more exactly with additional loops...). 
> > 
> > We've got at least the RX and TX queues.  That makes two locks and
> > two lists.
> 
> RX currently doesn't add anything to the list.

That's correct, currently ingress qdiscs only support a hierarchy of
single root and that's it.
