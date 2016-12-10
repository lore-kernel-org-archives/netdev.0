From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibmveth: set correct gso_size and gso_type
Date: Fri, 09 Dec 2016 22:48:15 -0500 (EST)
Message-ID: <20161209.224815.1152441346998572864.davem@davemloft.net>
References: <1477440555-21133-1-git-send-email-jmaxwell37@gmail.com>
        <1481236803-4807-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39884 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752090AbcLJDsT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 22:48:19 -0500
In-Reply-To: <1481236803-4807-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Thu,  8 Dec 2016 16:40:03 -0600

> This patch is based on an earlier one submitted
> by Jon Maxwell with the following commit message:
> 
> "We recently encountered a bug where a few customers using ibmveth on the
> same LPAR hit an issue where a TCP session hung when large receive was
> enabled. Closer analysis revealed that the session was stuck because the
> one side was advertising a zero window repeatedly.
> 
> We narrowed this down to the fact the ibmveth driver did not set gso_size
> which is translated by TCP into the MSS later up the stack. The MSS is
> used to calculate the TCP window size and as that was abnormally large,
> it was calculating a zero window, even although the sockets receive buffer
> was completely empty."
> 
> We rely on the Virtual I/O Server partition in a pseries
> environment to provide the MSS through the TCP header checksum
> field. The stipulation is that users should not disable checksum
> offloading if rx packet aggregation is enabled through VIOS.
> 
> Some firmware offerings provide the MSS in the RX buffer.
> This is signalled by a bit in the RX queue descriptor.
> 
> Reviewed-by: Brian King <brking@linux.vnet.ibm.com>
> Reviewed-by: Pradeep Satyanarayana <pradeeps@linux.vnet.ibm.com>
> Reviewed-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Reviewed-by: Jonathan Maxwell <jmaxwell37@gmail.com>
> Reviewed-by: David Dai <zdai@us.ibm.com>
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

Applied, although mis-using the TCP checksum field for this is kind of
bogus.  I'm surprised there wasn't some other place you could stick
this value, which wouldn't modify the packet contents.
