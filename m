From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH 0/9 Rev3] Implement batching skb API and support in
 IPoIB
Date: Sat, 25 Aug 2007 19:45:48 -0400
Message-ID: <20070825194548.8709cb38.billfink@mindspring.com>
References: <46CE0BA1.60206@hp.com>
	<20070823231820.2ae52cc0.billfink@mindspring.com>
	<1187957657.4255.35.camel@localhost>
	<20070824.142503.30177455.davem@davemloft.net>
	<20070824231100.GA30660@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	rick.jones2@hp.com, krkumar2@in.ibm.com, gaagaan@gmail.com,
	general@lists.openfabrics.org, jagana@us.ibm.com, jeff@garzik.org,
	johnpol@2ka.mipt.ru, kaber@trash.net, mcarlson@broadcom.com,
	mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, rdreier@cisco.com,
	Robert.Olsson@data.slu.se, shemminger@linux-foundation.org,
	sri@us.ibm.com, tgraf@suug.ch, xma@us.ibm.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:39342 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751228AbXHYXsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2007 19:48:05 -0400
In-Reply-To: <20070824231100.GA30660@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 25 Aug 2007, Herbert Xu wrote:

> On Fri, Aug 24, 2007 at 02:25:03PM -0700, David Miller wrote:
> >
> > My hunch is that even if in the non-TSO case the TX packets were all
> > back to back in the cards TX ring, TSO still spits them out faster on
> > the wire.
> 
> If this is the case then we should see an improvement by
> disabling TSO and enabling GSO.

TSO disabled and GSO enabled:

[root@lang2 redhat]# nuttcp -w10m 192.168.88.16
11806.7500 MB /  10.00 sec = 9900.6278 Mbps 100 %TX 84 %RX

[root@lang2 redhat]# nuttcp -M1460 -w10m 192.168.88.16
 4872.0625 MB /  10.00 sec = 4085.5690 Mbps 100 %TX 64 %RX

In the "-M1460" case, there was generally less receiver CPU utilization,
but the transmitter utilization was generally pegged at 100 %, even
though there wasn't any improvement in throughput compared to the
TSO enabled case (in fact the throughput generally seemed to be somewhat
less than the TSO enabled case).  Note there was a fair degree of
variability across runs for the receiver CPU utilization (the one
shown I considered to be representative of the average behavior).

Repeat of previous test results:

TSO enabled and GSO disabled:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11813.4375 MB /  10.00 sec = 9906.1644 Mbps 99 %TX 80 %RX

[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5102.8503 MB /  10.06 sec = 4253.9124 Mbps 39 %TX 99 %RX

TSO disabled and GSO disabled:

[root@lang2 ~]# nuttcp -w10m 192.168.88.16
11818.2500 MB /  10.00 sec = 9910.0176 Mbps 100 %TX 78 %RX

[root@lang2 ~]# nuttcp -M1460 -w10m 192.168.88.16
 5399.5625 MB /  10.00 sec = 4527.9070 Mbps 99 %TX 76 %RX

						-Bill
