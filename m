From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: After a while of system running no incoming UDP any more?
Date: Fri, 28 Jul 2017 10:15:02 +0200
Message-ID: <1501229702.2597.3.camel@redhat.com>
References: <20170724120901.6bpcieyvn5nccm2l@torres.zugschlus.de>
         <1500905950.2458.6.camel@redhat.com>
         <20170728062644.bp7agcf6bh7g6yfw@torres.zugschlus.de>
         <1501229105.12695.23.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Marc Haber <mh+netdev@zugschlus.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34850 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751113AbdG1IPE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Jul 2017 04:15:04 -0400
In-Reply-To: <1501229105.12695.23.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, 2017-07-28 at 01:05 -0700, Eric Dumazet wrote:
> On Fri, 2017-07-28 at 08:26 +0200, Marc Haber wrote:
> > On Mon, Jul 24, 2017 at 04:19:10PM +0200, Paolo Abeni wrote:
> > > Once that a system enter the buggy status, do the packets reach the
> > > relevant socket's queue?
> > > 
> > > ss -u
> > > nstat |grep -e Udp -e Ip
> > > 
> > > will help checking that.
> > 
> > I now have the issue on one machine, a Xen guest acting as authoritative
> > nameserver for my domains. Here are the outputs during normal use, with
> > artificial queries coming in on eth0:
> > 
> > [9/1075]mh@impetus:~ $ ss -u
> > Recv-Q Send-Q                                     Local Address:Port                                                      Peer Address:Port                
> > 0      0                                              127.0.0.1:56547                                                        127.0.0.1:domain               
> > 0      0                                         216.231.132.60:27667                                                       198.41.0.4:domain               
> > 0      0                                         216.231.132.60:44121                                                          8.8.8.8:domain               
> > 0      0                                         216.231.132.60:29814                                                       198.41.0.4:domain               
> > [10/1076]mh@impetus:~ $ ss -u
> > Recv-Q Send-Q                                     Local Address:Port                                                      Peer Address:Port                
> > [11/1076]mh@impetus:~ $ ss -u
> > Recv-Q Send-Q                                     Local Address:Port                                                      Peer Address:Port                
> > [12/1076]mh@impetus:~ $ ss -u
> > Recv-Q Send-Q                                     Local Address:Port                                                      Peer Address:Port                
> > [13/1076]mh@impetus:~ $ ss -u
> > Recv-Q Send-Q                                     Local Address:Port                                                      Peer Address:Port                
> > [14/1076]mh@impetus:~ $ nstat  | grep -e Udp -e Ip
> > IpInReceives                    400688             0.0
> > IpInAddrErrors                  18567              0.0
> > IpInUnknownProtos               3                  0.0
> > IpInDelivers                    330634             0.0
> > IpOutRequests                   283637             0.0
> > UdpInDatagrams                  145860             0.0
> > UdpNoPorts                      1313               0.0
> > UdpInErrors                     9356               0.0
> > UdpOutDatagrams                 153093             0.0
> > UdpIgnoredMulti                 34148              0.0
> > Ip6InReceives                   161178             0.0
> > Ip6InNoRoutes                   8                  0.0
> > Ip6InDelivers                   73841              0.0
> > Ip6OutRequests                  77575              0.0
> > Ip6InMcastPkts                  87332              0.0
> > Ip6OutMcastPkts                 109                0.0
> > Ip6InOctets                     21880674           0.0
> > Ip6OutOctets                    9633059            0.0
> > Ip6InMcastOctets                9371483            0.0
> > Ip6OutMcastOctets               6636               0.0
> > Ip6InNoECTPkts                  161202             0.0
> > Ip6InECT1Pkts                   15                 0.0
> > Ip6InECT0Pkts                   11                 0.0
> > Ip6InCEPkts                     4                  0.0
> > Udp6InDatagrams                 11725              0.0
> > Udp6NoPorts                     2                  0.0
> > Udp6InErrors                    1989               0.0
> > Udp6OutDatagrams                14483              0.0
> > IpExtInBcastPkts                34148              0.0
> > IpExtInOctets                   47462716           0.0
> > IpExtOutOctets                  31262696           0.0
> > IpExtInBcastOctets              7476059            0.0
> > IpExtInNoECTPkts                400178             0.0
> > IpExtInECT1Pkts                 22                 0.0
> > IpExtInECT0Pkts                 481                0.0
> > IpExtInCEPkts                   14                 0.0
> > [15/1077]mh@impetus:~ $ nstat  | grep -e Udp -e Ip
> > IpInReceives                    25                 0.0
> > IpInDelivers                    25                 0.0
> > IpOutRequests                   16                 0.0
> > UdpInDatagrams                  1                  0.0
> > UdpInErrors                     24                 0.0
> > UdpOutDatagrams                 16                 0.0
> > Ip6InReceives                   15                 0.0
> > Ip6InDelivers                   14                 0.0
> > Ip6OutRequests                  12                 0.0
> > Ip6InMcastPkts                  1                  0.0
> > Ip6InOctets                     1219               0.0
> > Ip6OutOctets                    4384               0.0
> > Ip6InMcastOctets                131                0.0
> > Ip6InNoECTPkts                  15                 0.0
> > IpExtInOctets                   11779              0.0
> > IpExtOutOctets                  1023               0.0
> > IpExtInNoECTPkts                25                 0.0
> > [16/1077]mh@impetus:~ $ nstat  | grep -e Udp -e Ip
> > IpInReceives                    24                 0.0
> > IpInDelivers                    24                 0.0
> > IpOutRequests                   18                 0.0
> > UdpInErrors                     22                 0.0
> > UdpOutDatagrams                 16                 0.0
> > Ip6InReceives                   15                 0.0
> > Ip6InDelivers                   12                 0.0
> > Ip6OutRequests                  10                 0.0
> > Ip6InMcastPkts                  3                  0.0
> > Ip6InOctets                     1160               0.0
> > Ip6OutOctets                    2456               0.0
> > Ip6InMcastOctets                216                0.0
> > Ip6InNoECTPkts                  15                 0.0
> > IpExtInOctets                   8612               0.0
> > IpExtOutOctets                  1127               0.0
> > IpExtInNoECTPkts                24                 0.0
> > [17/1077]mh@impetus:~ $ nstat  | grep -e Udp -e Ip
> > IpInReceives                    5                  0.0
> > IpInDelivers                    4                  0.0
> > IpOutRequests                   3                  0.0
> > UdpNoPorts                      1                  0.0
> > UdpInErrors                     2                  0.0
> > UdpOutDatagrams                 1                  0.0
> > Ip6InReceives                   12                 0.0
> > Ip6InDelivers                   12                 0.0
> > Ip6OutRequests                  10                 0.0
> > Ip6InOctets                     944                0.0
> > Ip6OutOctets                    2364               0.0
> > Ip6InNoECTPkts                  12                 0.0
> > IpExtInOctets                   429                0.0
> > IpExtOutOctets                  226                0.0
> > IpExtInNoECTPkts                5                  0.0
> > [18/1077]mh@impetus:~ $
> > 
> > And here, hopefully a bit more helpful:
> > 
> > [19/1078]mh@impetus:~ $ ss -u ; nstat  | grep -e Udp -e Ip ; dig +time=2 @8.8.8.8 zugschlus.de mx ; ss -u ; nstat  | grep -e Udp -e Ip 
> > Recv-Q Send-Q                                     Local Address:Port                                                      Peer Address:Port                
> > 0      0                                         216.231.132.60:27333                                                       198.41.0.4:domain               
> > 0      0                                         216.231.132.60:38101                                                       198.41.0.4:domain               
> > 0      0                                         216.231.132.60:15836                                                       198.41.0.4:domain               
> > 0      0                                         216.231.132.60:50655                                                          8.8.8.8:domain               
> > 0      0                                         216.231.132.60:41953                                                       198.41.0.4:domain               
> > 0      0                                         216.231.132.60:6888                                                        198.41.0.4:domain               
> > 0      0                                         216.231.132.60:51441                                                       198.41.0.4:domain               
> > 0      0                                         216.231.132.60:42503                                                       198.41.0.4:domain               
> > 0      0                                         216.231.132.60:12575                                                       198.41.0.4:domain               
> > 0      0                                         216.231.132.60:13857                                                       198.41.0.4:domain
> > 0      0                                         216.231.132.60:16419                                                    192.36.148.17:domain
> > 0      0                                         216.231.132.60:39227                                                       198.41.0.4:domain
> > 0      0                                              127.0.0.1:54608                                                        127.0.0.1:domain
> > 0      0                                         216.231.132.60:20818                                                       198.41.0.4:domain
> > 0      0                                         216.231.132.60:56662                                                       198.41.0.4:domain
> > 0      0                                         216.231.132.60:48259                                                    192.36.148.17:domain
> > 0      0                                         216.231.132.60:37803                                                       198.41.0.4:domain
> > IpInReceives                    59                 0.0
> > IpInAddrErrors                  1                  0.0
> > IpInDelivers                    56                 0.0
> > IpOutRequests                   50                 0.0
> > UdpInDatagrams                  1                  0.0
> > UdpInErrors                     50                 0.0
> > UdpOutDatagrams                 47                 0.0
> > UdpIgnoredMulti                 1                  0.0
> > Ip6InReceives                   75                 0.0
> > Ip6InDelivers                   73                 0.0
> > Ip6OutRequests                  64                 0.0
> > Ip6InMcastPkts                  2                  0.0
> > Ip6InOctets                     7837               0.0
> > Ip6OutOctets                    11876              0.0
> > Ip6InMcastOctets                279                0.0
> > Ip6InNoECTPkts                  75                 0.0
> > Udp6InErrors                    3                  0.0
> > IpExtInBcastPkts                1                  0.0
> > IpExtInOctets                   18447              0.0
> > IpExtOutOctets                  3478               0.0
> > IpExtInBcastOctets              183                0.0
> > IpExtInNoECTPkts                59                 0.0
> > 
> > ; <<>> DiG 9.10.3-P4-Debian <<>> +time=2 @8.8.8.8 zugschlus.de mx
> > ; (1 server found)
> > ;; global options: +cmd
> > ;; connection timed out; no servers could be reached
> > Recv-Q Send-Q                                     Local Address:Port                                                      Peer Address:Port
> > 0      0                                         216.231.132.60:7879                                                      202.12.27.33:domain
> > 0      0                                         216.231.132.60:32711                                                     202.12.27.33:domain
> > 0      0                                         216.231.132.60:54238                                                     202.12.27.33:domain
> > 0      0                                         216.231.132.60:30948                                                   192.228.79.201:domain
> > 0      0                                         216.231.132.60:4106                                                      202.12.27.33:domain
> > 0      0                                         216.231.132.60:6667                                                      202.12.27.33:domain
> > 0      0                                         216.231.132.60:2090                                                    192.228.79.201:domain
> > 0      0                                         216.231.132.60:60459                                                   192.228.79.201:domain
> > 0      0                                         216.231.132.60:16427                                                     202.12.27.33:domain
> > 0      0                                         216.231.132.60:9019                                                      202.12.27.33:domain
> > 0      0                                         216.231.132.60:2113                                                      202.12.27.33:domain
> > 0      0                                         216.231.132.60:34907                                                     202.12.27.33:domain
> > 0      0                                         216.231.132.60:34654                                                     202.12.27.33:domain
> > 0      0                                         216.231.132.60:47725                                                     202.12.27.33:domain
> > 0      0                                         216.231.132.60:35774                                                     202.12.27.33:domain
> > IpInReceives                    38                 0.0
> > IpInDelivers                    38                 0.0
> > IpOutRequests                   38                 0.0
> > UdpInDatagrams                  2                  0.0
> > UdpInErrors                     34                 0.0
> > UdpOutDatagrams                 36                 0.0
> > Ip6InReceives                   14                 0.0
> > Ip6InDelivers                   13                 0.0
> > Ip6OutRequests                  13                 0.0
> > Ip6InMcastPkts                  1                  0.0
> > Ip6InOctets                     1046               0.0
> > Ip6OutOctets                    6277               0.0
> > Ip6InMcastOctets                133                0.0
> > Ip6InNoECTPkts                  13                 0.0
> > Ip6InECT0Pkts                   1                  0.0
> > Udp6InDatagrams                 1                  0.0
> > Udp6OutDatagrams                1                  0.0
> > IpExtInOctets                   15963              0.0
> > IpExtOutOctets                  2397               0.0
> > IpExtInNoECTPkts                37                 0.0
> > IpExtInECT0Pkts                 1                  0.0
> > [20/1079]mh@impetus:~ $
> > 
> > I am afraid I cannot keep this state for much longer than a few
> > additional hours as this is an authoritative name server...
> > 
> > Greetings
> > Marc
> > 
> 
> To confirm the refcount issue, you might send us :
> 
> cat /proc/net/udp6
> 
> Normally, the refcount column should have a value of 2

I think that the leaked sockets are still unhashed on close() (via
udp_lib_close() -> sk_common_release() ->sk_proto->unhash()), so they
should not be listed there ?!? (Rush answer, subject to lack of coffee
issues)

Thanks,

Paolo
