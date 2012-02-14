From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: RE: [PATCH] bnx2x: preserve net device stats across reload
Date: Mon, 13 Feb 2012 23:08:48 -0800
Message-ID: <FD96C117992C584DBC47231B1EB6F556B00B33AF39@SJEXCHCCR02.corp.ad.broadcom.com>
References: <1329154898-17188-1-git-send-email-mschmidt@redhat.com>
 <D4345541C14421439B1167B74C9F3835371370@SJEXCHMB05.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>
To: "mschmidt@redhat.com" <mschmidt@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1429 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753131Ab2BNHJI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 02:09:08 -0500
In-Reply-To: <D4345541C14421439B1167B74C9F3835371370@SJEXCHMB05.corp.ad.broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The network device statistics were reset to zero when the bnx2x driver
> reloaded the NIC, such as when changing the MTU.
> 
> To preserve the statistics across reloads, save the current values when
> unloading. Add the saved values to the values read currently from the
> hardware when updating the stats. Forget the saved values if the reason
> for unloading is that the device is going down.
 
Thanks for this patch -  indeed there is currently a problem with statistics 
reset during inner reloads such as MTU changes. 

However, notice that keeping the net_device_stats statistics consistent 
across such changes is only a very partial solution, since most of the 
statistics will still be reset. E.g., bp->eth_stats will be reset, causing ethtool 
to output zero statistics after such an inner reload.

I'm currently working on a patch to fix this issue. Since my patch will make
the statistics in bnx2x_eth_stats consistent after an inner reload, 
the changes made here will be unrequired, since all the net_device_stats 
are direct products of bnx2x_eth_stats (with the exception of one field).

I will try to submit it later on today.
