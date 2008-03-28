From: Harald Hannelius <harald@iki.fi>
Subject: Re: tg3 bad performance, lots of hardware interrupts
Date: Fri, 28 Mar 2008 19:31:01 +0200 (EET)
Message-ID: <alpine.DEB.1.00.0803281925500.5286@penti.org>
References: <alpine.DEB.1.00.0803271532570.30549@penti.org> <20080327.144925.196529669.davem@davemloft.net> <1206666100.5368.6.camel@dell> <alpine.DEB.1.00.0803281440460.23558@penti.org> <1206726560.6866.5.camel@dell>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from penti.org ([193.167.33.200]:60288 "EHLO penti.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753680AbYC1RbJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 13:31:09 -0400
In-Reply-To: <1206726560.6866.5.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 28 Mar 2008, Michael Chan wrote:
> On Fri, 2008-03-28 at 15:04 +0200, Harald Hannelius wrote:

>> Phew, I thought that running ethtool -t was like doing stop-A-sync on
>> a
>> Sun. It took almost half an hour to run that ethtool -t command;
>
> Something is very wrong.  ethtool -t should only take a few seconds to
> complete.  You can try ethtool -t eth0 online to reduce the number of
> tests to see if it makes a difference.

Here's the output of ethtool -t eth2:

The test result is PASS
The test extra info:
nvram test     (online)          0
link test      (online)          0
register test  (offline)         0
memory test    (offline)         0
loopback test  (offline)         0
interrupt test (offline)         0

I just started a 'ethtool -t eth2 online' and that one took just some 10 
seconds or so.

# ethtool -t eth2 online 2>&1 | tee ethtool-output.log
The test result is PASS
The test extra info:
nvram test     (online) 	 0
link test      (online) 	 0
register test  (offline)	 0
memory test    (offline)	 0
loopback test  (offline)	 0
interrupt test (offline)	 0
# mpstat 2 2>&1 | tee ethtool2.log
Linux 2.6.24.4 (mauer) 	03/28/2008

05:22:42 PM  CPU   %user   %nice    %sys %iowait    %irq   %soft  %steal   %idle    intr/s
05:22:44 PM  all    0.00    0.00    0.00    0.00   11.63    7.56    0.00   80.81    102.99
05:22:46 PM  all    0.00    0.00    0.27    0.00    8.33    4.84    0.00   86.56    123.00
05:22:48 PM  all    0.00    0.00    0.00    0.00   12.03    7.16    0.00   80.80    108.46
05:22:50 PM  all    0.00    0.00    0.00    0.00   10.47    5.23    0.00   84.30    113.93
05:22:52 PM  all    0.00    0.00    0.00    0.00   12.93   10.06    0.00   77.01    135.00
05:22:55 PM  all    0.00    0.00   18.11    0.00   24.25   12.62    0.00   45.02    158.28
05:22:57 PM  all    0.00    0.00    0.82    0.00   13.11   10.38    0.00   75.68    146.04
05:22:59 PM  all    0.00    0.00    0.29    0.00   18.77   12.61    0.00   68.33    136.32
05:23:01 PM  all    0.00    0.00    0.00    0.00   13.64    7.67    0.00   78.69    112.50
05:23:03 PM  all    0.00    0.00    0.00    0.00    9.19    4.86    0.00   85.95    110.50
05:23:05 PM  all    0.00    0.00    0.00    0.00   13.64    7.67    0.00   78.69    108.00

> How many of these NICs do you have?  If you have more than one, do they
> all behave the same way?  Have they ever worked well before?

It's a brand spanking new computer, equipped with three of these BCM5751 
NICs made by HP. I have ripped out all but one, and I have also tested the 
NIC in all three available PCIe slots. Same result.

When all three NIC's where plugged in they didn't work. All three behave 
the same one-by-one.

I don't know if they have worked before.

-- 
A: Top Posters!                                      |  s/y Charlotta |
Q: What is the most annoying thing on mailing lists? |    FIN-2674    |
   http://www.fe83.org/ Finn Express Purjehtijat ry   |  ============= |
Harald H Hannelius | harald (At) iki (dot) fi | GSM +358 50 594 1020
