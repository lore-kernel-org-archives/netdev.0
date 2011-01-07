From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH] ehea: Add some info messages and fix an issue
Date: Fri, 7 Jan 2011 14:24:30 +1100
Message-ID: <20110107142430.42fda498@kryten>
References: <1290790908.11971.303.camel@Joe-Laptop>
	<1290792387-12331-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org, davem@davemloft.net
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:39581 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751866Ab1AGDYd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 22:24:33 -0500
In-Reply-To: <1290792387-12331-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> From: Breno Leitao <breno@cafe.(none)>
> 
> This patch adds some debug information about ehea not being able to
> allocate enough spaces. Also it correctly updates the amount of
> available skb.

I'm seeing issues on a number of machines with the ehea device.
Sometime after boot I see a bunch of:

ehea: Error in ehea_proc_rwqes: LL rq1: skb=NULL
ehea: Error in ehea_proc_rwqes: LL rq1: skb=NULL
ehea: Error in ehea_proc_rwqes: LL rq1: skb=NULL
ehea: Error in ehea_proc_rwqes: LL rq1: skb=NULL

which eventually stop.

-       for (i = 0; i < pr->rq1_skba.len; i++) {
+       for (i = 0; i < nr_rq1a; i++) {

It looks like you are now only initialising half the ring, but still
telling the hardware to use the whole ring. Once you get through the
entire ring once the errors go away.

Anton
