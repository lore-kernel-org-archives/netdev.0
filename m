From: Bruce Allen <ballen@gravity.phys.uwm.edu>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Fri, 1 Feb 2008 01:54:24 -0600 (CST)
Message-ID: <Pine.LNX.4.63.0802010140330.29449@trinity.phys.uwm.edu>
References: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu>
 <36D9DB17C6DE9E40B059440DB8D95F52044F81DF@orsmsx418.amr.corp.intel.com>
 <Pine.LNX.4.63.0801301635470.19938@trinity.phys.uwm.edu>
 <36D9DB17C6DE9E40B059440DB8D95F52044F8BA3@orsmsx418.amr.corp.intel.com>
 <Pine.LNX.4.63.0801310213010.3240@trinity.phys.uwm.edu> <47A20E9E.7070503@intel.com>
 <Pine.LNX.4.63.0801311251040.14403@trinity.phys.uwm.edu> <47A22241.70600@intel.com>
 <Pine.LNX.4.63.0801311340270.14403@trinity.phys.uwm.edu>
 <20080201012732.232b7859.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>,
	Bruce Allen <bruce.allen@aei.mpg.de>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from trinity.phys.uwm.edu ([129.89.57.159]:45509 "EHLO
	trinity.phys.uwm.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752518AbYBAHyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 02:54:39 -0500
In-Reply-To: <20080201012732.232b7859.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Bill,

> I started musing if once one side's transmitter got the upper hand, it 
> might somehow defer the processing of received packets, causing the 
> resultant ACKs to be delayed and thus further slowing down the other 
> end's transmitter.  I began to wonder if the txqueuelen could have an 
> affect on the TCP performance behavior.  I normally have the txqueuelen 
> set to 10000 for 10-GigE testing, so decided to run a test with 
> txqueuelen set to 200 (actually settled on this value through some 
> experimentation).  Here is a typical result:
>
> [bill@chance4 ~]$ nuttcp -f-beta -Itx -w2m 192.168.6.79 & nuttcp -f-beta -Irx -r -w2m 192.168.6.79
> tx:  1120.6345 MB /  10.07 sec =  933.4042 Mbps 12 %TX 9 %RX 0 retrans
> rx:  1104.3081 MB /  10.09 sec =  917.7365 Mbps 12 %TX 11 %RX 0 retrans
>
> This is significantly better, but there was more variability in the
> results.  The above was with TSO enabled.  I also then ran a test
> with TSO disabled, with the following typical result:
>
> [bill@chance4 ~]$ nuttcp -f-beta -Itx -w2m 192.168.6.79 & nuttcp -f-beta -Irx -r -w2m 192.168.6.79
> tx:  1119.4749 MB /  10.05 sec =  934.2922 Mbps 13 %TX 9 %RX 0 retrans
> rx:  1131.7334 MB /  10.05 sec =  944.8437 Mbps 15 %TX 12 %RX 0 retrans
>
> This was a little better yet and getting closer to expected results.

We'll also try changing txqueuelen.  I have not looked, but I suppose that 
this is set to the default value of 1000.  We'd be delighted to see 
full-duplex performance that was consistent and greater than 900 Mb/s x 2.

> I do have some other test systems at work that I might be able to try 
> with newer kernels and/or drivers or maybe even with other vendor's GigE 
> NICs, but I won't be back to work until early next week sometime.

Bill, we'd be happy to give you root access to a couple of our systems 
here if you want to do additional testing.  We can put the latest drivers 
on them (and reboot if/as needed).  If you want to do this, please just 
send an ssh public key to Carsten.

Cheers,
 	Bruce
