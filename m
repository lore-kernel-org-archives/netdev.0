From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/7] ibmvnic: Add is_up flag to avoid
 transmits when driver is down
Date: Sun, 09 Apr 2017 14:30:24 -0700 (PDT)
Message-ID: <20170409.143024.691078252187673837.davem@davemloft.net>
References: <20170409040328.47642.33535.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
        <20170409041132.47642.81315.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com, brking@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com
To: nfont@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60872 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751272AbdDIVa3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Apr 2017 17:30:29 -0400
In-Reply-To: <20170409041132.47642.81315.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Date: Sun, 09 Apr 2017 00:11:32 -0400

> From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
> 
> There are brief windows when handling events such as failover where we
> could attempt to transmit packets between receiving the transport event
> notification and handling the reset in the workqueue.
> 
> This patch introduces an is_up flag so we can avoid transmit attempts at
> these times.
> 
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
> Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>

Simply stop the netdev queue when the device is in this state.
The kernel will stop queueing packets to the device if you do
that.

Please do not add unnecessary extra state and logic for this,
it doesn't appear to be necessary.

Thank you.
