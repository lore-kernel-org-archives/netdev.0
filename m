From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] CUBIC v2.3 with new improved slow start
Date: Wed, 29 Oct 2008 15:39:28 -0700
Message-ID: <20081029153928.3d47e26f@extreme>
References: <006001c93a0d$477d4e30$4a580e98@ncsu2cc0c3fa00>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "Injong Rhee" <rhee@eos.ncsu.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60621 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751464AbYJ2Wje (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Oct 2008 18:39:34 -0400
In-Reply-To: <006001c93a0d$477d4e30$4a580e98@ncsu2cc0c3fa00>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 Oct 2008 17:28:26 -0400
"Injong Rhee" <rhee@eos.ncsu.edu> wrote:

> I am releasing a new patch for CUBIC. This patch implements a new slow start 
> mechanism called HyStart. There were some discussions in the mailing list on 
> the poor performance of TCP slow start; our patch addresses those 
> performance issues arising from slow start.  For more information, please 
> refer to the following technical report:
> 
>  Sangtae Ha and Injong Rhee, "Taming the Elephants: New TCP Slow
> Start", NCSU Technical Report 2008. Available at
> http://netsrv.csc.ncsu.edu/export/hystart_techreport_2008.pdf
> 
> 
> The new update improves the start-up throughput of CUBIC substantially by 
> avoiding system overloading during slow start and shortening the 
> fast-recovery period after slow start. The key performance issues arising 
> when Linux is used with Windows XP or FreeBSD receivers are also addressed. 
> Our tests over Internet2 paths are very encouraging. The scheme is verified 
> to work well even for asymmetric paths,  with diverse receiver settings of 
> delayed acknowledgements, and with various operating systems (Windows XP and 
> FreeBSD). You can find the testing results from
> 
> http://netsrv.csc.ncsu.edu/wiki/index.php/TCP_Testing
> 
> Please let us know if there are other performance issues of TCP that you 
> want us to look into.
> 
> Injong and Sangtae.
> 

This looks like a good optimization, it obviously needs more testing
because Linux always seems to find new broken hardware.  The areas
that need to be tested should include:
  * MacOs has a broken version of delayed ack that might cause
    HyStart to radically underestimate.
  * Applications that dribble out packets might get better (or
    worse) performance.  This include dumb web servers.
  * Does this increase or reduce latency when using TCP for
    applications which never fill the congestion window? (games, financial, etc).
