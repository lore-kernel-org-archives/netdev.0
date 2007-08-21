From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9 Rev3] Implement batching skb API and support in
 IPoIB
Date: Tue, 21 Aug 2007 00:18:24 -0700 (PDT)
Message-ID: <20070821.001824.105429474.davem@davemloft.net>
References: <OFFFECFAD7.CF3FF115-ON6525733A.0020AE37-6525733A.00218365@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gaagaan@gmail.com, general@lists.openfabrics.org, hadi@cyberus.ca,
	herbert@gondor.apana.org.au, jagana@us.ibm.com, jeff@garzik.org,
	johnpol@2ka.mipt.ru, kaber@trash.net, kumarkr@linux.ibm.com,
	mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, rdreier@cisco.com,
	rick.jones2@hp.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@us.ibm.com, tgraf@suug.ch,
	xma@us.ibm.com
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54292
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750841AbXHUHS0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 03:18:26 -0400
In-Reply-To: <OFFFECFAD7.CF3FF115-ON6525733A.0020AE37-6525733A.00218365@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krishna Kumar2 <krkumar2@in.ibm.com>
Date: Fri, 17 Aug 2007 11:36:03 +0530

> > I ran 3 iterations of 45 sec tests (total 1 hour 16 min, but I will
> > run a longer one tonight). The results are (results in KB/s, and %):
> 
> I ran a 8.5 hours run with no batching + another 8.5 hours run with
> batching (Buffer sizes: "32 128 512 4096 16384", Threads: "1 8 32",
> Each test run time: 3 minutes, Iterations to average: 5). TCP seems
> to get a small improvement.

Using 16K buffer size really isn't going to keep the pipe full enough
for TSO.  And realistically applications queue much more data at a
time.  Also, with smaller buffer sizes can have negative effects for
the dynamic receive and send buffer growth algorithm the kernel uses,
it might consider the connection application limited for too long.

I would really prefer to see numbers that use buffer sizes more in
line with the amount of data that is typically inflight on a 1G
connection on a local network.

Do a tcpdump during the height of the transfer to see about what this
value is.  When an ACK comes in, compare the sequence number it's
ACK'ing with the sequence number of the most recently sent frame.
The difference is approximately the pipe size at maximum congestion
window assuming a loss free local network.
