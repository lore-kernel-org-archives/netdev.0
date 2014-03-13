From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: [Patch 1/2] IB/mlx5: Implementation of PCI error handler
Date: Thu, 13 Mar 2014 18:03:59 +0200
Message-ID: <20140313160359.GB28066@mtldesk30>
References: <20140312034219.637916521@linux.vnet.ibm.com>
 <20140312034512.065218504@linux.vnet.ibm.com>
 <1394649252.23624.36.camel@deadeye.wl.decadent.org.uk>
 <20140313064521.GH20224@mtldesk30>
 <5321CAD3.2070301@linux.vnet.ibm.com>
 <20140313154002.GA28066@mtldesk30>
 <5321D412.1040501@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <ben@decadent.org.uk>, eli@mellanox.com,
	roland@kernel.org, sean.hefty@intel.com, hal.rosenstock@gmail.com,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	brking@linux.vnet.ibm.com
To: Carol Soto <clsoto@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:41487 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbaCMQED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 12:04:03 -0400
Received: by mail-ee0-f53.google.com with SMTP id e51so497234eek.26
        for <netdev@vger.kernel.org>; Thu, 13 Mar 2014 09:04:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5321D412.1040501@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 13, 2014 at 10:51:46AM -0500, Carol Soto wrote:
> 
> The motivation to reduce that timeout is that if there is a process
> in the middle of a HW command
> in the middle of the PCI error, I probably did not want to wait 2hrs
> since the command will never complete
> since the card is dead. Now you are right, I forgot the case of big
> memory registration where commands can
> take longer than that. Do you have an idea of what is the longest
> time that a command can take in mlx5?
>

There is no guranteed time for command completions. With current
driver/firmware, registration of 4.5 GB can take around 2 minutes; for
larger regions it can take even more time. As I mentioned earlier, I
will soon send a patch that reduces registation times for large
regions.
