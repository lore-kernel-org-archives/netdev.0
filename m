From: "Injong Rhee" <rhee@ncsu.edu>
Subject: Re: [PATCH] CUBIC v2.3 with new improved slow start
Date: Wed, 29 Oct 2008 19:14:03 -0400
Message-ID: <000b01c93a1c$090222c0$6c01a8c0@RHEELAPTOP>
References: <006001c93a0d$477d4e30$4a580e98@ncsu2cc0c3fa00> <20081029153928.3d47e26f@extreme>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="ISO-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@vyatta.com>,
	"Injong Rhee" <rhee@eos.ncsu.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.121]:43043 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754607AbYJ2XOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 19:14:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> This looks like a good optimization, it obviously needs more testing
> because Linux always seems to find new broken hardware.  The areas
> that need to be tested should include:
>  * MacOs has a broken version of delayed ack that might cause
>    HyStart to radically underestimate.

We tested with FreeBSD. I presume that it covers MacOS. We will look into 
that.

>  * Applications that dribble out packets might get better (or
>    worse) performance.  This include dumb web servers.

Not really. It does not affect those flows that do not use their full 
capacity of the network. HyStart kicks in only when the flow are using more 
than avail bw during slow start. If the applications do not pump data in, it 
would still be in slow start -- while in slow start, HyStart works like the 
traditional slow start (double cwnd per rtt).

>  * Does this increase or reduce latency when using TCP for
>    applications which never fill the congestion window? (games, financial, 
> etc).
>

For the same reasons as above, No, HyStart does not engage in this 
situation. 

