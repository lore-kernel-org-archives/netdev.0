From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH][RFC] Re: high latency with TCP connections
Date: Fri, 22 Sep 2006 10:15:47 -0700
Message-ID: <45141A43.8020306@hp.com>
References: <20060830100734.GA22235@isil.ipib.msu.ru>	<20060904160045.GA15599@ms2.inr.ac.ru> <44FDBA04.3080104@hp.com>	<20060918.003938.26278728.davem@davemloft.net>	<450ED337.8000700@hp.com> <20060918204105.GA31333@ms2.inr.ac.ru>	<450F0EA5.2020109@hp.com> <20060918225123.GA22150@ms2.inr.ac.ru>	<450F3BC7.4020603@hp.com> <20060922134642.GA10175@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, alex@sectorb.msk.ru,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:58007 "EHLO palrel10.hp.com")
	by vger.kernel.org with ESMTP id S964790AbWIVRPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 13:15:50 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060922134642.GA10175@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Kuznetsov wrote:
> Hello!
> 
> 
>>transactions to data segments is fubar.  That issue is also why I wonder 
>>about the setting of tcp_abc.
> 
> 
> Yes, switching ABC on/off has visible impact on amount of segments.
> When ABC is off, amount of segments is almost the same as number of
> transactions. When it is on, ~1.5% are merged. But this is invisible
> in numbers of throughput/cpu usage.

Hmm, that would seem to suggest that for "new" the netperf/netserver 
were being fast enough that the code didn't perceive the receipt of 
back-to-back sub-MSS segments? (Is that even possible once -b is fairly 
large?)  Otherwise, with new I would have expected the segment count to 
be meaningfully > than the transaction count?

> 
> That' numbers:
> 
> 1Gig link. The first column is "b". - separates runs of netperf
> in backward direction.
> 
> Run #1. One host is slower.
> 
>         old,abc=0
> 	 new,abc=0
> 	  new,abc=1
> 	   old,abc=1
> 
> 2	23652.00  6.31   21.11  10.665  8.924
> 	 23622.16  6.47   21.01  10.951  8.893
> 	  23625.05  6.21   21.01  10.512  8.891
> 	   23725.12  6.46   20.31  10.898  8.559
> 	-
> 	23594.87  21.90  6.44   9.283   10.912
> 	 23631.52  20.30  6.36   8.592   10.766
> 	  23609.55  21.00  6.26   8.896   10.599
> 	   23633.75  21.10  5.44   8.929   9.206
> 
> 4	36349.11  8.71   31.21  9.584   8.585
> 	 36461.37  8.65   30.81  9.492   8.449
> 	  36723.72  8.22   31.31  8.949   8.526
> 	   35801.24  8.58   30.51  9.589   8.521
> 	-
> 	35127.34  33.80  8.43   9.621   9.605
> 	 36165.50  30.90  8.48   8.545   9.381
> 	  36201.45  31.10  8.31   8.592   9.185
> 	   35269.76  30.00  8.58   8.507   9.732
> 
> 8	41148.23  10.39  42.30  10.101  10.281
> 	 41270.06  11.04  31.31  10.698  7.585
> 	  41181.56  5.66   48.61  5.496   11.803
> 	   40372.37  9.68   56.50  9.591   13.996
> 	-
> 	40392.14  47.00  11.89  11.637  11.775
> 	 40613.80  36.90  9.16   9.086   9.019
> 	  40504.66  53.60  7.73   13.234  7.639
> 	   40388.99  48.70  11.93  12.058  11.814
> 
> 16	67952.27  16.27  43.70  9.576   6.432
> 	 68031.40  10.56  53.70  6.206   7.894
> 	  67777.95  12.81  46.90  7.559   6.920
> 	   67814.41  16.13  46.50  9.517   6.857
> 	-
> 	68031.46  51.30  11.53  7.541   6.781
> 	 68044.57  40.70  8.48   5.982   4.986
> 	  67808.13  39.60  15.86  5.840   9.355
> 	   67818.32  52.90  11.51  7.801   6.791
> 
> 32	90445.09  15.41  99.90  6.817   11.045
> 	 90210.34  16.11  100.00 7.143   11.085
> 	  90221.84  17.31  98.90  7.676   10.962
> 	   90712.78  18.41  99.40  8.120   10.958
> 	-
> 	89155.51  99.90  12.89  11.205  5.782
> 	 90058.54  99.90  16.16  11.093  7.179
> 	  90092.31  98.60  15.41  10.944  6.840
> 	   88688.96  99.00  17.59  11.163  7.933
> 
> 64	89983.76  13.66  100.00 6.071   11.113
> 	 90504.24  17.54  100.00 7.750   11.049
> 	  92043.36  17.44  99.70  7.580   10.832
> 	   90979.29  16.01  99.90  7.038   10.981
> 	-
> 	88615.27  99.90  14.91  11.273  6.729
> 	 89316.13  99.90  17.28  11.185  7.740
> 	  90622.85  99.90  16.81  11.024  7.420
> 	   89084.85  99.90  17.51  11.214  7.861
> 
> Run #2. Slower host is replaced with better one. ABC=0.
> No runs in backward directions.
> 
> 	new
> 	 old
> 
> 2	24009.73  8.80   6.49   3.667   10.806
> 	 24008.43  8.00   6.32   3.334   10.524
> 4	40012.53  18.30  8.79   4.574   8.783
> 	 39999.84  19.40  8.86   4.851   8.857
> 8	60500.29  26.30  12.78  4.348   8.452
> 	 60397.79  26.30  11.73  4.355   7.769
> 16	69619.95  39.80  14.03  5.717   8.063
> 	 70528.72  24.90  14.43  3.531   8.184
> 32	132522.01  53.20  21.28  4.015   6.424
> 	 132602.93  57.70  22.59  4.351   6.813
> 64	145738.83  60.30  25.01  4.138   6.865
> 	 143129.55  73.20  24.19  5.114   6.759
> 128	148184.21  69.70  24.96  4.704   6.739
> 	 148143.47  71.00  25.01  4.793   6.753
> 256	144798.91  69.40  25.01  4.793   6.908
> 	 144086.01  73.00  24.61  5.067   6.832
> 
> Frankly, I do not see any statistically valid correlations.

Does look like it jumps-around quite a bit - for example the run#2 with 
-b 16 had the CPU util all over the map on the netperf side.  That 
wasn't by any chance an SMP system?

>>that "linux" didn't seem to be doing the same thing. Hence my tweaking 
>>when seeing this patch come along...]
> 
> 
> netperf does not catch this. :-)

Nope :(  One of these days.... I need to teach netperf how to extract 
TCP statistics from as many platforms as possible.  Meantime it relies 
as always on the kindness of benchmarkers :) (My appologies to Tennesee 
Williams :)

> Even with this patch linux does not ack each second segment dumbly,
> it waits for some conditions, mostly read() emptying receive queue.

Good.  HP-UX is indeed dumb about this, but I'm assured it will be 
changing.  I forget what Solaris does in this situation - I thought I 
looked a while ago but cannot recall the result.

> To model this it is necessary to insert some gaps between
> bursted segments or to use slow network.
> 
> I have no doubts it is easy to model a situation when we send
> lots of useless ACKs. F.e. inserting 20ms gaps between requests.
> To see effect on thoughput/cpu, we could start enough of connections,
> doing the same thing.

Adding --enable-intervals might work there.  I don't recall how well it 
gets along with --enable-burst though, and you have already made lots of 
runs as it is.

rick
