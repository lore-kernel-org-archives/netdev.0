From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [PATCH 2.6.27] ixgbe: initialize interrupt throttle rate
Date: Wed, 27 Aug 2008 15:48:14 -0700
Message-ID: <1219877294.30033.4.camel@jbrandeb-ich9b.jf.intel.com>
References: <20080827215014.GA14386@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org,
	jeffrey.t.kirsher@intel.com, bruce.w.allan@intel.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:53706 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752301AbYH0WsQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 18:48:16 -0400
In-Reply-To: <20080827215014.GA14386@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-08-27 at 17:50 -0400, Andy Gospodarek wrote:
> This commit dropped the setting of the default interrupt throttle rate.
> 
> commit 021230d40ae0e6508d6c717b6e0d6d81cd77ac25
> Author: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>
> Date:   Mon Mar 3 15:03:45 2008 -0800
>     
>     ixgbe: Introduce MSI-X queue vector code
>     
> The following patch adds it back.  Without this the default value of 0
> causes the performance of this card to be awful.  Restoring these to the
> default values yields much better performance.
> 
> This regression has been around since 2.6.25.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> CC: stable@kernel.org [2.6.25 and later]

We hadn't heard about this, but more specifically, this bug effects UDP
transmit performance because the interrupt rate on the tx vectors was so
low.  Here is what I got in testing against 2.6.27-rc3, there was no
appreciable difference testing with TCP on a back to back setup.

before
======
[root linux-2.6]# netperf -H lh2-10 -t UDP_STREAM -C -c
UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
lh2-10 (10.0.0.1) port 0 AF_INET
Socket  Message  Elapsed      Messages                   CPU
Service
Size    Size     Time         Okay Errors   Throughput   Util     Demand
bytes   bytes    secs            #      #   10^6bits/sec % SS     us/KB

112640   65507   10.00        1964      0      102.9     26.35    90.483
122880           10.00        1821              95.4     1.35     4.643 

after patch
===========
[root linux-2.6]# netperf -H lh2-10 -t UDP_STREAM -C -c
UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
lh2-10 (10.0.0.1) port 0 AF_INET
Socket  Message  Elapsed      Messages                   CPU
Service
Size    Size     Time         Okay Errors   Throughput   Util     Demand
bytes   bytes    secs            #      #   10^6bits/sec % SS     us/KB

112640   65507   10.00       51641      0     2706.2     32.63    5.016 
122880           10.00       40675            2131.5     30.95    4.758 

Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

