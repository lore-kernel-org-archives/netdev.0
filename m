From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: sunvnet NAPIfication
Date: Wed, 15 Oct 2014 10:05:00 -0400
Message-ID: <20141015140500.GA11183@oracle.com>
References: <20141002201203.GA6001@oracle.com>
 <20141002.134346.2291749763304558513.davem@davemloft.net>
 <20141003144024.GA12448@oracle.com>
 <20141003.120802.1213573830649867131.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:48816 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751288AbaJOOFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 10:05:11 -0400
Content-Disposition: inline
In-Reply-To: <20141003.120802.1213573830649867131.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I have the NAPIfication-of-sunvnet patch-set ready for 
code review. AFAIK net-next is not currently open
for new features this week, but does it make sense for
me to go ahead and send the patch-set to the list (I'm sure
it will take some time to review) or will that just create
confusion to the netdev maintainers?

--Sowmini

Previously discussed:

> >> For example, you can now move everything into software IRQ context,
> >> just disable the VIO interrupt and unconditionally go into NAPI
> >> context from the VIO event.
> >> No more irqsave/irqrestore.
> >> Then the TX path even can run mostly lockless, it just needs
> >> to hold the VIO lock for a minute period of time.  The caller
> >> holds the xmit_lock of the network device to prevent re-entry
> >> into the ->ndo_start_xmit() path.
> 
> I think you should be able to get rid of all of the in-driver
> locking in the fast paths.
> 
> NAPI ->poll() is non-reentrant, so all RX processing occurs
> strictly in a serialized environment.
> 
> Once you do TX reclaim in NAPI context, then all you have to do is
> take the generic netdev TX queue lock during the evaluation of whether
> to wakeup the TX queue or not.  Worst case you need to hold the
> TX netdev queue lock across the whole TX reclaim operation.
> 
> The VIO lock really ought to be entirely superfluous in the data
> paths.
