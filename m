From: Matt Leininger <mlleinin@hpcn.ca.sandia.gov>
Subject: Re: Timeline of IPoIB performance
Date: Mon, 10 Oct 2005 16:25:07 -0700
Message-ID: <1128986707.13945.424.camel@localhost>
References: <1128672413.13948.326.camel@localhost>
	<52br20lsei.fsf@cisco.com> <1128738350.13945.369.camel@localhost>
	<521x2tgrim.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Roland Dreier <rolandd@cisco.com>
In-Reply-To: <521x2tgrim.fsf@cisco.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

On Mon, 2005-10-10 at 11:23 -0700, Roland Dreier wrote:
>      > 2.6.12-rc5      in-kernel    1     405   <<<<<
>      > 2.6.12-rc4      in-kernel    1     470   <<<<<
> 
> I was optimistic when I saw this, because the changeover to git
> occurred with 2.6.12-rc2, so I thought I could use git bisect to track
> down exactly when the performance regression happened.
> 
> However, I haven't been able to get numbers that are stable enough to
> track this down.  I have two systems, both HP DL145s with dual Opteron
> 875s and two-port mem-free PCI Express HCAs.  I use MSI-X with the
> completion interrupt affinity set to CPU 0, and "taskset 2" to run
> netserver and netperf on CPU 1.
> 
> With default netperf parameters (just "-H otherguy") I get numbers
> between ~490 MB/sec and ~550 MB/sec for 2.6.12-rc4 and 2.6.12-rc5.
> The numbers are quite consistent between reboots, but if I reboot the
> system (even keeping the kernel identical), I see large performance
> changes.  Presumably something is happening like the cache coloring of
> some hot data structures changing semi-randomly depending on the
> timing of various initialations.
> 
> Matt, how stable are your numbers?


  Pretty consistent.  Here are a few runs with 2.6.12-rc5 with reboots
in between each run.  I'm using netperf-2.3pl1.

Run 1:
TCP STREAM TEST to 10.128.20.6
Recv   Send    Send                          Utilization       Service
Demand
Socket Socket  Message  Elapsed              Send     Recv     Send
Recv
Size   Size    Size     Time     Throughput  local    remote   local
remote
bytes  bytes   bytes    secs.    KBytes  /s  % T      % T      us/KB
us/KB

 87380  16384  16384    10.00      410302.39   99.89    92.09    4.869
4.489

Run 2: (after another reboot)
TCP STREAM TEST to 10.128.20.6
Recv   Send    Send                          Utilization       Service
Demand
Socket Socket  Message  Elapsed              Send     Recv     Send
Recv
Size   Size    Size     Time     Throughput  local    remote   local
remote
bytes  bytes   bytes    secs.    KBytes  /s  % T      % T      us/KB
us/KB

 87380  16384  16384    10.00      409510.33   99.89    91.59    4.879
4.473

Run 3: (after reboot)
TCP STREAM TEST to 10.128.20.6
Recv   Send    Send                          Utilization       Service
Demand
Socket Socket  Message  Elapsed              Send     Recv     Send
Recv
Size   Size    Size     Time     Throughput  local    remote   local
remote
bytes  bytes   bytes    secs.    KBytes  /s  % T      % T      us/KB
us/KB

 87380  16384  16384    10.00      404354.11   99.89    91.39    4.941
4.520


I see the same variance in netperf results if I don't reboot between
runs.  

  - Matt



  


> 
  
