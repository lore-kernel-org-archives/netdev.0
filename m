From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ibmvnic: Make CRQ interrupt tasklet wait for all
 capabilities crqs
Date: Sun, 19 Feb 2017 18:12:22 -0500 (EST)
Message-ID: <20170219.181222.1275918068118644004.davem@davemloft.net>
References: <1487182680-29421-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
        <1487182680-29421-3-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nfont@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54590 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751382AbdBSXM7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2017 18:12:59 -0500
In-Reply-To: <1487182680-29421-3-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Wed, 15 Feb 2017 12:18:00 -0600

> After sending device capability queries and requests to the vNIC Server,
> an interrupt is triggered and the responses are written to the driver's
> CRQ response buffer. Since the interrupt can be triggered before all
> responses are written and visible to the partition, there is a danger
> that the interrupt handler or tasklet can terminate before all responses
> are read, resulting in a failure to initialize the device.
> 
> To avoid this scenario, when capability commands are sent, we set
> a flag that will be checked in the following interrupt tasklet that
> will handle the capability responses from the server. Once all
> responses have been handled, the flag is disabled; and the tasklet
> is allowed to terminate.
> 
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

Applied.
