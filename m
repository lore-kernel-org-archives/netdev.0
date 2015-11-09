From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next network throughput performance regression
Date: Mon, 09 Nov 2015 15:04:38 -0800
Message-ID: <1447110278.17135.53.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CY1PR03MB13760C9F1AABC4EBC455B85CC4280@CY1PR03MB1376.namprd03.prod.outlook.com>
 <563D1180.60206@cumulusnetworks.com>
 <CY1PR03MB13763CB0C0A9C822660E248AC4280@CY1PR03MB1376.namprd03.prod.outlook.com>
 <563D1BE0.2070107@cumulusnetworks.com>
 <1446924959.17135.23.camel@edumazet-glaptop2.roam.corp.google.com>
 <1446925821.17135.24.camel@edumazet-glaptop2.roam.corp.google.com>
 <CY1PR03MB13761B2731BF4FA3748D73B7C4150@CY1PR03MB1376.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Haiyang Zhang <haiyangz@microsoft.com>, "ohering@suse.com" <ohering@suse.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 David Ahern <dsa@cumulusnetworks.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 David Miller <davem@davemloft.net>
To: Simon Xiao <sixiao@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <CY1PR03MB13761B2731BF4FA3748D73B7C4150@CY1PR03MB1376.namprd03.prod.outlook.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Mon, 2015-11-09 at 20:23 +0000, Simon Xiao wrote:
> Thanks Eric to provide the data. I am looping Tom (as I am looking into his recent patches) and Olaf (from Suse).
> 
> So, if I understand it correctly, you are running netperf with single
> TCP connection, and you got ~26Gbps initially and got ~30Gbps after
> turning the tx-usecs and tx-frames.
> 
> Do you have a baseline on your environment for the best/max/or peak
> throughput?

The peak on my lab pair is about 34Gbits, usually I get this if I pin
the receiving thread on a cpu, otherwise process scheduler can really
hurt too much.

lpaa23:~# DUMP_TCP_INFO=1 ./netperf -H lpaa24 -l 20 -Cc -T ,1
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to lpaa24.prod.google.com () port 0 AF_INET : cpu bind
tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 29200
tcpi_rtt 101 tcpi_rttvar 15 tcpi_snd_ssthresh 289 tpci_snd_cwnd 289
tcpi_reordering 3 tcpi_total_retrans 453
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    20.00      33975.99   1.27     3.36     0.147   0.389  

Not too bad, I don't recall reaching more than that ever.
