From: Lawrence Brakmo <brakmo@fb.com>
Subject: Re: tcp: add NV congestion control
Date: Thu, 27 Aug 2015 05:52:51 +0000
Message-ID: <D203F1C4.733A%brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Kernel Team <Kernel-team@fb.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: Lawrence Brakmo <brakmo@fb.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:55070 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752164AbbH0FxG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2015 01:53:06 -0400
Content-Language: en-US
Content-ID: <905C5EEA644DBD439521D1F7BFDF895D@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The updated NV document with the new experiments and a table with all the
experimental results are now available at
(http://www.brakmo.org/networking/tcp-nv/TCPNV.html).

- Lawrence
 

On 8/25/15, 4:33 PM, "Lawrence Brakmo" <brakmo@fb.com> wrote:

>Changes from v5: cleaning of NV code, changing some default parameters
>
>I've run more extensive tests, I'm working on updating the NV website
>(http://www.brakmo.org/networking/tcp-nv/TCPNV.html) should be updated
>by tomorrow (8/26).
>
>The updated tests include Reno, Cubic, NV and CDG and include more types
>of traffic. Overview of results:
>1) NV has a little lower throughput (2-3% less) with small number of flows
>   as compared to Reno, Cubic and CDG
>2) NV is less fair with few flows but becomes more fair with more flows
>3) Less losses with NV (none in many cases) as compared to all others.
>   One exception is when things get very congested (64 flows into one
>   server), NV has 50% more losses than CDG, Cubic has 1.8x to 10x more
>   losses than CDG. Reno has about the same losses as CDG.
>4) In mixed traffic (1M and 10K RPCs), 10K flows achieve much higher
>   average throughput with NV than with the others (which are
>   very similar). In one example, 2 clients sending 1M and 10K to 2
>   servers, with NV 10K flows average 1Gbps and 1M flows 3.7Gbps,
>   whereas they average about 226Mbps and 4.4Gbps for Reno, Cubic and
>   CDG. They all have similar link utilization.
>
>Consists of the following patches:
>
>[RFC PATCH v6 net-next 1/4] tcp: replace cnt & rtt with struct in
>[RFC PATCH v6 net-next 2/4] tcp:  refactor struct tcp_skb_cb
>[RFC PATCH v6 net-next 3/4] tcp: add in_flight to tcp_skb_cb
>[RFC PATCH v6 net-next 4/4] tcp: add NV congestion control
>
>Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
>
>include/net/tcp.h       |  20 ++-
>net/ipv4/Kconfig        |  16 ++
>net/ipv4/Makefile       |   1 +
>net/ipv4/tcp_bic.c      |   6 +-
>net/ipv4/tcp_cdg.c      |  14 +-
>net/ipv4/tcp_cubic.c    |   6 +-
>net/ipv4/tcp_htcp.c     |  10 +-
>net/ipv4/tcp_illinois.c |  20 +--
>net/ipv4/tcp_input.c    |  10 +-
>net/ipv4/tcp_lp.c       |   6 +-
>net/ipv4/tcp_nv.c       | 489
>++++++++++++++++++++++++++++++++++++++++++++++++++++++
>net/ipv4/tcp_output.c   |   4 +-
>net/ipv4/tcp_vegas.c    |   6 +-
>net/ipv4/tcp_vegas.h    |   2 +-
>net/ipv4/tcp_veno.c     |   7 +-
>net/ipv4/tcp_westwood.c |   7 +-
>net/ipv4/tcp_yeah.c     |   7 +-
>17 files changed, 580 insertions(+), 51 deletions(-)
