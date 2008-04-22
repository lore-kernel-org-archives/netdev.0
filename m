From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [ PATCH 1/1 2.6.25-rc9] bnx2: Add EEH support in bnx2x
 driver
Date: Tue, 22 Apr 2008 14:46:31 -0700
Message-ID: <1208900791.13806.5.camel@dell>
References: <1208812834.24768.40.camel@wendyx.austin.ibm.com>
 <1208823296.16633.230.camel@dell>
 <1208893442.7339.17.camel@wendyx.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, jeff@garzik.org,
	"David Miller" <davem@davemloft.net>
To: "wendy xiong" <wendyx@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3076 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761986AbYDVUmp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2008 16:42:45 -0400
In-Reply-To: <1208893442.7339.17.camel@wendyx.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-04-22 at 14:44 -0500, wendy xiong wrote:
> >Shouldn't we attach first before netif_start?
> 
> From my understanding, network interface function dev->open will call
> device driver's open function to initialize internal data structures
> and
> enable interrupt, then driver starts the receive queue by calling
> netif_start_queue.
> 
> Looks bnx2_netif_start() enables hardware interrupt and receive
> polling
> interrupt. So I think we can do netif_device_attach after
> bnx2_netif_start() according to dev->open route concept.
> 

I think it doesn't make a whole lot of difference either way, especially
if you hold the rtnl_lock().  But in the normal course of loading the
driver, the LINK_STATE_PRESENT bit gets set during ->probe() when the
driver calls register_netdev().  So it is attached before ->open().

