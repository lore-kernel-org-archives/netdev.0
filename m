From: David Ahern <dsahern@gmail.com>
Subject: Re: Low speed MPLS to virtio-net
Date: Sat, 29 Apr 2017 14:50:15 -0600
Message-ID: <85812f46-8822-fbc4-0ac1-f9a714661462@gmail.com>
References: <428971493234129@web14g.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: =?UTF-8?B?0JDQu9C10LrRgdC10Lkg0JHQvtC70LTRi9GA0LXQsg==?=
        <ne-vlezay80@yandex.ru>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:34364 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755570AbdD2UuT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Apr 2017 16:50:19 -0400
Received: by mail-pg0-f41.google.com with SMTP id v1so29909221pgv.1
        for <netdev@vger.kernel.org>; Sat, 29 Apr 2017 13:50:19 -0700 (PDT)
In-Reply-To: <428971493234129@web14g.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/26/17 1:15 PM, Алексей Болдырев wrote:
> Started MPLS on the branch - Everything was fine. When I tried to run MPLS on a real network of virtual machines, there were problems with the speed:
> root@containers:~# iperf3 -c 10.194.10.2 -B 10.194.10.1 -Z       
> Connecting to host 10.194.10.2, port 5201
> [  4] local 10.194.10.1 port 49533 connected to 10.194.10.2 port 5201
> [ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
> [  4]   0.00-1.00   sec  1018 KBytes  8.34 Mbits/sec  238   5.64 KBytes       
> [  4]   1.00-2.00   sec  1.42 MBytes  11.9 Mbits/sec  373   1.41 KBytes       
> [  4]   2.00-3.00   sec  1.43 MBytes  12.0 Mbits/sec  379   5.64 KBytes       
> [  4]   3.00-4.00   sec  1.43 MBytes  12.0 Mbits/sec  376   5.64 KBytes       
> [  4]   4.00-5.00   sec  1.41 MBytes  11.8 Mbits/sec  375   2.82 KBytes       
> [  4]   5.00-6.00   sec  1.42 MBytes  11.9 Mbits/sec  376   2.82 KBytes       
> [  4]   6.00-7.00   sec  1.42 MBytes  11.9 Mbits/sec  373   5.64 KBytes       
> [  4]   7.00-8.00   sec  1.41 MBytes  11.8 Mbits/sec  372   5.64 KBytes       
> [  4]   8.00-9.00   sec  1.42 MBytes  11.9 Mbits/sec  379   2.82 KBytes       
> [  4]   9.00-10.00  sec  1.42 MBytes  11.9 Mbits/sec  373   5.64 KBytes       
> - - - - - - - - - - - - - - - - - - - - - - - - -
> [ ID] Interval           Transfer     Bandwidth       Retr
> [  4]   0.00-10.00  sec  13.8 MBytes  11.5 Mbits/sec  3614             sender
> [  4]   0.00-10.00  sec  13.6 MBytes  11.4 Mbits/sec                  receiver

A picture of your network topology is more helpful than dumping network
config commands.


For this topology:

                             10.10.10.10
  +-----+       +-----+       +-----+
  | VM1 |-------| VM2 |-------| VM3 |
  +-----+       +-----+       +-----+
 push 100        pop 100


I get 4+ Gbps using netperf from VM1 to VM3:

$ netperf -c -C -H 10.10.10.10  -l 10 -t TCP_STREAM
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
10.10.10.10 () port 0 AF_INET
Recv   Send    Send                          Utilization       Service
Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local
remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    10.01      4377.58   37.69    60.78    1.411   2.275


So your bandwidth above is really low.

I suggest you confirm a good bandwidth without MPLS to make sure the VM
config is proper.
