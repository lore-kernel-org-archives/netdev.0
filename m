From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC] ipv4: support for request type gratuitous ARP
Date: Mon, 11 Jan 2010 23:31:37 +0200
Message-ID: <201001112331.37187.opurdila@ixiacom.com>
References: <201001050004.45004.opurdila@ixiacom.com> <20100110.132105.179935794.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:21721 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751372Ab0AKVfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 16:35:05 -0500
In-Reply-To: <20100110.132105.179935794.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 10 January 2010 23:21:05 you wrote:
> From: Octavian Purdila <opurdila@ixiacom.com>
> Date: Tue, 5 Jan 2010 00:04:44 +0200
> 
> > Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> > ---
> >
> > I've noticed that even though we currently support response type
> > gratuitous ARP [response type, source mac, dest mac, source IP, source
> > IP] *with a clean ARP table* we do not support the request type [request
> > type, source mac, ff:ff:ff:ff:ff:ff, source IP, source IP].
> 
> Please don't submit your patches in this manner.
> 
> All of these relevant, interesting, details belong in the commit
> message.  But any text you place aftr the "---" line will be omitted
> from the commit message when your patch is applied by automated GIT
> tools.
> 

Got it.

> I've done some research and I'm happy to apply your patch to
> net-next-2.6 once it is submitted properly.
> 

Thanks, I'll resubmitted it properly in a bit.

> In fact we need to do some more research in this area because
> generally we should more mimick the processing order of ARP prescribed
> in the RFC.  In particular we should test the operation code lastly,
> which would avoid these kinds of inconsistencies.
> 
> I'm worried though about security issues as well, as we make more the
> acceptance more and more liberal, it becomes that much easier for
> machines on the local network to poison ARP entries and use that to
> either accept all traffic destined for a particular node or simply
> deny that node access to the network.
> 
> In particular the kernel currently explicitly does not accept
> unsolicited ARP, and this is controlled by the ARP_ACCEPT per-device
> option.
> 
> 	if (IPV4_DEVCONF_ALL(dev_net(dev), ARP_ACCEPT)) {
> 		/* Unsolicited ARP is not accepted by default.
> 		   It is possible, that this option should be enabled for some
> 		   devices (strip is candidate)
> 		 */
> ...
> 

Good point, I'll try to respin the patch to do this check for the request type 
gratuitous ARP as well.

Thanks!

