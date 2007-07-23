From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 00/10] Implement batching skb API
Date: Mon, 23 Jul 2007 09:53:29 +0530
Message-ID: <OF00C1E678.386A9C8E-ON65257321.0017122B-65257321.00181FC6@in.ibm.com>
References: <20070720125423.GB13468@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, gaagaan@gmail.com,
	general@lists.openfabrics.org, hadi@cyberus.ca,
	herbert@gondor.apana.org.au, jagana@us.ibm.com, jeff@garzik.org,
	kaber@trash.net, kumarkr@linux.ibm.com, mcarlson@broadcom.com,
	mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, rdreier@cisco.com,
	rick.jones2@hp.com, Robert.Olsson@data.slu.se, sri@us.ibm.com,
	tgraf@suug.ch, xma@us.ibm.com
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:36987 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233AbXGWEXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 00:23:43 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l6N4l1v8324354
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2007 14:47:01 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6N4RCf2177728
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2007 14:27:13 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6N4NcKL010950
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2007 14:23:40 +1000
In-Reply-To: <20070720125423.GB13468@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Evgeniy,

Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote on 07/20/2007 06:24:23 PM:

> Hi Krishna.
>
> On Fri, Jul 20, 2007 at 12:01:49PM +0530, Krishna Kumar
(krkumar2@in.ibm.com) wrote:
> > After fine-tuning qdisc and other changes, I modified IPoIB to use this
API,
> > and now get good gains. Summary for TCP & No Delay: 1 process improves
for
> > all cases from 1.4% to 49.5%; 4 process has almost identical
improvements
> > from -1.7% to 59.1%; 16 process case also improves in the range of
-1.2% to
> > 33.4%; while 64 process doesn't have much improvement (-3.3% to 12.4%).
UDP
> > was tested with 1 process netperf with small increase in BW but big
> > improvement in Service Demand. Netperf latency tests show small drop in
> > transaction rate (results in separate attachment).
>
> What about round-robin tcp time and latency test? In theory such batching
> mode should not change that timings, but practice can show new aspects.

The TCP RR results show a slight impact, however the service demand shows
good improvement. The results are (I did TCP RR - 1 process, 1,8,32,128,512
buffer sizes; and UDP RR - 1 process, 1 byte buffer size) :

        Results for TCR RR (1 process) ORG code:
Size        R-R                   CPU%            S.Demand
------------------------------------------------------------
1         521346.02               5.48            1346.145
8         129463.14               6.74            418.370
32        128899.73               7.51            467.106
128       127230.15               5.42            340.876
512       119605.68               6.48            435.650


        Results for TCR RR (1 process) NEW code (and change%):
Size        R-R                   CPU%            S.Demand
--------------------------------------------------------------------
1         516596.62 (-0.91%)      5.74            1423.819 (5.77%)
8         129184.46 (-.22%)       5.43            336.747 (-19.51%)
32        128238.35 (-.51%)       5.43            339.213 (-27.38%)
128       126545.79 (-.54%)       5.36            339.188 (-0.50%)
512       119297.49 (-.26%)       5.16            346.185 (-20.54%)


              Results for UDP RR 1 process ORG & NEW code:
Code   Size      R-R                CPU%      S.Demand
----------------------------------------------------------------------
ORG     1        539327.86          5.68      1348.985
NEW     1        540669.33 (0.25%)  6.05      1434.180 (6.32%)


> I will review code later this week (likely tomorrow) and if there will
> be some issues return back.

Thanks! I had just submitted Rev2 on Sunday, please let me know what you
find.

Regards,

- KK

