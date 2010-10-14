From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [v2 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Thu, 14 Oct 2010 18:17:47 +0530
Message-ID: <OF25EFB1A7.96C6DDCF-ON652577BC.0045F696-652577BC.004603BD@in.ibm.com>
References: <cover.1286372004.git.mst@redhat.com> <OF6C412DBC.EA03FC24-ON652577B9.00228DCA-652577B9.0028232D@in.ibm.com> <20101012170907.GA30613@redhat.com> <OFA7630B83.BFDFF71D-ON652577BC.0026D199-652577BC.002B9158@in.ibm.com> <20101014081723.GC11095@redhat.com> <OFEC86A094.39835EBF-ON652577BC.002F9AAF-652577BC.003186B5@LocalDomain> <OF0BDA6B3A.F673A449-ON652577BC.00422911-652577BC.0043474B@LocalDomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <OF0BDA6B3A.F673A449-ON652577BC.00422911-652577BC.0043474B@LocalDomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krishna Kumar2/India/IBM wrote on 10/14/2010 05:47:54 PM:

Sorry, it should read "txq=8" below.

- KK

> There's a significant reduction in CPU/SD utilization with your
> patch. Following is the performance of ORG vs MQ+mm patch:
>
> _________________________________________________
>                Org vs MQ+mm patch txq=2
> #     BW%     CPU/RCPU%         SD/RSD%
> _________________________________________________
> 1     2.26    -1.16    .27      -20.00  0
> 2     35.07   29.90    21.81     0      -11.11
> 4     55.03   84.57    37.66     26.92  -4.62
> 8     73.16   118.69   49.21     45.63  -.46
> 16    77.43   98.81    47.89     24.07  -7.80
> 24    71.59   105.18   48.44     62.84  18.18
> 32    70.91   102.38   47.15     49.22  8.54
> 40    63.26   90.58    41.00     85.27  37.33
> 48    45.25   45.99    11.23     14.31  -12.91
> 64    42.78   41.82    5.50      .43    -25.12
> 80    31.40   7.31     -18.69    15.78  -11.93
> 96    27.60   7.79     -18.54    17.39  -10.98
> 128   23.46   -11.89   -34.41    -.41   -25.53
> _________________________________________________
> BW: 40.2  CPU/RCPU: 29.9,-2.2   SD/RSD: 12.0,-15.6
>
> Following is the performance of MQ vs MQ+mm patch:
> _____________________________________________________
>             MQ vs MQ+mm patch
> #     BW%      CPU%       RCPU%    SD%      RSD%
> _____________________________________________________
> 1      4.98    -.58       .84      -20.00    0
> 2      5.17     2.96      2.29      0       -4.00
> 4     -.18      .25      -.16       3.12     .98
> 8     -5.47    -1.36     -1.98      17.18    16.57
> 16    -1.90    -6.64     -3.54     -14.83   -12.12
> 24    -.01      23.63     14.65     57.61    46.64
> 32     .27     -3.19      -3.11    -22.98   -22.91
> 40    -1.06    -2.96      -2.96    -4.18    -4.10
> 48    -.28     -2.34      -3.71    -2.41    -3.81
> 64     9.71     33.77      30.65    81.44    77.09
> 80    -10.69    -31.07    -31.70   -29.22   -29.88
> 96    -1.14     5.98       .56     -11.57   -16.14
> 128   -.93     -15.60     -18.31   -19.89   -22.65
> _____________________________________________________
>   BW: 0   CPU/RCPU: -4.2,-6.1  SD/RSD: -13.1,-15.6
> _____________________________________________________
>
> Each test case is for 60 secs, sum over two runs (except
> when number of netperf sessions is 1, which has 7 runs
> of 10 secs each), numcpus=4, numtxqs=8, etc. No tuning
> other than taskset each vhost to cpus 0-3.
>
> Thanks,
>
> - KK

