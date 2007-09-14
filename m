From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [RESEND] Implement batching skb API and support in IPoIB
Date: Fri, 14 Sep 2007 14:22:34 +0530
Message-ID: <OFAAE6E03F.ADFF5A98-ON65257356.0030A56B-65257356.0030C23E@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: gaagaan@gmail.com, general@lists.openfabrics.org, hadi@cyberus.ca,
	herbert@gondor.apana.org.au, jagana@us.ibm.com, jeff@garzik.org,
	johnpol@2ka.mipt.ru, kaber@trash.net, kumarkr@linux.ibm.com,
	mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, rdreier@cisco.com,
	rick.jones2@hp.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@us.ibm.com, tgraf@suug.ch,
	xma@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from E23SMTP02.au.ibm.com ([202.81.18.163]:39630 "EHLO
	e23smtp02.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750943AbXINIvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 04:51:21 -0400
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8E8os9m002945
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 18:50:54 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8E8orc04276274
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 18:50:53 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8E8ooca003464
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 18:50:53 +1000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Dave,

I am re-sending in case you didn't get this earlier. Also sending REV5 of
the patch.
I will send patch for e1000e on monday or tuesday after making the changes
and
testing over the weekend.

thanks,

- KK

__________________

Hi Dave,

David Miller <davem@davemloft.net> wrote on 08/29/2007 10:21:50 AM:

> From: Krishna Kumar2 <krkumar2@in.ibm.com>
> Date: Wed, 29 Aug 2007 08:53:30 +0530
>
> > I am scp'ng from 192.168.1.1 to 192.168.1.2 and captured at the send
> > side.
>
> Bad choice of test, this is cpu limited since the scp
> has to encrypt and MAC hash all the data it sends.
>
> Use something like straight ftp or "bw_tcp" from lmbench.

I used bw_tcp from lmbench-3. I transfered 500MB and captured
the tcpdump, and analysis at various points gave pipeline sizes:

26064, 27792, 22888, 23168, 23448, 20272, 23168, 4344, 10136,
164792, 35920, 26344, 24336, 24336, 23168, 25784, 23168,

There was one huge 164K, otherwise most were in smaller ranges
like 20-30K. I ran the following test script:

SERVER=192.168.1.2
BYTES=100m
BUFFERSIZES="4096 16384 65536 131072 262144"
PROCS="1 8"
ITERATIONS=5

for m in $BUFFERSIZES
do
      for procs in $PROCS
      do
            echo TEST: Size:$m Procs:$procs
            bw_tcp -N $ITERATIONS -m $m -M $BYTES -P $procs $SERVER
      done
done

Result is:
Test without batching:
#       Size       Procs     BW (MB/s)
1       4096       1         117.39
2       16384      1         117.49
3       65536      1         117.55
4       131072     1         117.55
5       262144     1         117.58

6       4096       8         117.18
7       16384      8         117.47
8       65536      8         117.54
9       131072     8         117.59
10      262144     8         117.55

Test with batching:
#       Size       Procs     BW (MB/s)
1       4096       1         117.39
2       16384      1         117.48
3       65536      1         117.55
4       131072     1         117.58
5       262144     1         117.58

6       4096       8         117.19
7       16384      8         117.46
8       65536      8         117.53
9       131072     8         117.55
10      262144     8         117.60

So it doesn't seem to harm e1000.

Can someone give a link to the E1000E driver? I couldn't find it
after downloading Jeff's netdev-2.6 tree.

Thanks,

- KK

