From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 00/10]: Netfilter IPsec support
Date: Thu, 17 Nov 2005 03:35:37 +0100
Message-ID: <437BEC79.9040004@trash.net>
References: <BAY103-F240FCD8D8AE36A95868233B25D0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Marco Berizzi <pupilla@hotmail.com>
In-Reply-To: <BAY103-F240FCD8D8AE36A95868233B25D0@phx.gbl>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Marco Berizzi wrote:
> How are handled NAT-T packets (udp/4500) with these patches?

Instead of ESP packets you see the encapsulated UDP packets
on the netfilter hooks:

(none):~# ping 10.0.0.1 -c 1
PING 10.0.0.1 (10.0.0.1): 56 data bytes
OUTPUT      IN= OUT=eth0 SRC=10.0.0.2 DST=10.0.0.1 LEN=84 TOS=0x00 
PREC=0x00 TTL=64 ID=0 DF PROTO=ICMP TYPE=8 CODE=0 ID=16899 SEQ=0
POSTROUTING IN= OUT=eth0 SRC=10.0.0.2 DST=10.0.0.1 LEN=84 TOS=0x00 
PREC=0x00 TTL=64 ID=0 DF PROTO=ICMP TYPE=8 CODE=0 ID=16899 SEQ=0

OUTPUT      IN= OUT=eth0 SRC=10.0.0.2 DST=10.0.0.1 LEN=160 TOS=0x00 
PREC=0x00 TTL=64 ID=256 DF PROTO=UDP SPT=4500 DPT=4500 LEN=140
POSTROUTING IN= OUT=eth0 SRC=10.0.0.2 DST=10.0.0.1 LEN=160 TOS=0x00 
PREC=0x00 TTL=64 ID=256 DF PROTO=UDP SPT=4500 DPT=4500 LEN=140

PREROUTING  IN=eth0 OUT= MAC=fe:fd:0a:00:00:02:36:ec:4f:25:dc:68:08:00 
SRC=10.0.0.1 DST=10.0.0.2 LEN=160 TOS=0x00 PREC=0x00 TTL=64 ID=19709 
PROTO=UDP SPT=4500 DPT=4500 LEN=140
INPUT       IN=eth0 OUT= MAC=fe:fd:0a:00:00:02:36:ec:4f:25:dc:68:08:00 
SRC=10.0.0.1 DST=10.0.0.2 LEN=160 TOS=0x00 PREC=0x00 TTL=64 ID=19709 
PROTO=UDP SPT=4500 DPT=4500 LEN=140

PREROUTING  IN=eth0 OUT= MAC=fe:fd:0a:00:00:02:36:ec:4f:25:dc:68:08:00 
SRC=10.0.0.1 DST=10.0.0.2 LEN=84 TOS=0x00 PREC=0x00 TTL=64 ID=19708 
PROTO=ICMP TYPE=0 CODE=0 ID=16899 SEQ=0
INPUT       IN=eth0 OUT= MAC=fe:fd:0a:00:00:02:36:ec:4f:25:dc:68:08:00 
SRC=10.0.0.1 DST=10.0.0.2 LEN=84 TOS=0x00 PREC=0x00 TTL=64 ID=19708 
PROTO=ICMP TYPE=0 CODE=0 ID=16899 SEQ=0

64 bytes from 10.0.0.1: icmp_seq=0 ttl=64 time=25.9 ms
