From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] [NET_SCHED] explict hold dev tx lock
Date: Mon, 08 Oct 2007 14:05:22 -0700 (PDT)
Message-ID: <20071008.140522.57183793.davem@davemloft.net>
References: <1190677099.4264.37.camel@localhost>
	<20071007.215124.85709188.davem@davemloft.net>
	<1191850490.4352.41.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, krkumar2@in.ibm.com,
	johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, kaber@trash.net,
	shemminger@linux-foundation.org, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, rick.jones2@hp.com, xma@us.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	mcarlson@broadcom.com, jeff@garzik.org, mchan@broadcom.com,
	general@lists.openfabrics.org, kumarkr@linux.ibm.com,
	tgraf@suug.ch, randy.dunlap@oracle.com, sri@us.ibm.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39748
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754028AbXJHVFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 17:05:38 -0400
In-Reply-To: <1191850490.4352.41.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Mon, 08 Oct 2007 09:34:50 -0400

> The brain-block i am having is the parallelization aspect of it.
> Whatever scheme it is - it needs to ensure the scheduler works as
> expected. For example, if it was a strict prio scheduler i would expect
> that whatever goes out is always high priority first and never ever
> allow a low prio packet out at any time theres something high prio
> needing to go out. If i have the two priorities running on two cpus,
> then i cant guarantee that effect.
> IOW, i see the scheduler/qdisc level as not being split across parallel
> cpus. Do i make any sense?

Picture it like N tubes you stick packets into, and the tubes are
processed using DRR.

So packets within a tube won't be reordered, but reordering amongst
tubes is definitely possible.
