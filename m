From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] tcp: efficient port randomisation (revised)
Date: Fri, 03 Dec 2004 21:42:47 -0800
Message-ID: <41B14E57.5080803@osdl.org>
References: <20041027092531.78fe438c@guest-251-240.pdx.osdl.net>	<200411020854.44745.michael.vittrup.larsen@ericsson.com>	<20041104100104.570e67cd@dxpl.pdx.osdl.net>	<200411051103.59032.michael.vittrup.larsen@ericsson.com>	<20041117153025.160eaa04@zqx3.pdx.osdl.net>	<20041130214643.7b72300e.davem@davemloft.net>	<20041201152446.3a0d5ce3@dxpl.pdx.osdl.net>	<20041201204622.7b760400.davem@davemloft.net>	<20041202134930.132d7bd8@dxpl.pdx.osdl.net> <20041202135252.04e64f51.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: michael.vittrup.larsen@ericsson.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041202135252.04e64f51.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

If I special case to handle loopback, and get rid of the portalloc
lock, it comes out much better.  These numbers are on the 800Mhz
PIII SMP, on a fast box like the dual Opeteron's it makes no difference
(always 30us).

Before TCP connection latency mean 79.9 std 10.55

*Local* Communication latencies in microseconds - smaller is better
-------------------------------------------------------------------
Host                 OS 2p/0K  Pipe AF     UDP  RPC/   TCP  RPC/ TCP
                         ctxsw       UNIX         UDP         TCP conn
--------- ------------- ----- ----- ---- ----- ----- ----- ----- ----
stp2-001  Linux 2.6.10- 8.270  38.6 24.3  61.6  48.5  45.9  76.6 74.6
stp2-001  Linux 2.6.10- 8.170  43.5 24.5  58.0  54.8  45.6  63.4 74.7
stp2-001  Linux 2.6.10- 2.740  50.6 29.9  40.3  48.3  59.8  75.1 101.
stp2-001  Linux 2.6.10- 8.140  46.6 29.7  57.6  48.8  45.5  72.0 74.4
stp2-001  Linux 2.6.10- 2.690  47.1 26.3  40.8  48.9  45.5  75.4 74.8


After TCP connection latency mean 73.8 std 0.55

*Local* Communication latencies in microseconds - smaller is better
-------------------------------------------------------------------
Host                 OS 2p/0K  Pipe AF     UDP  RPC/   TCP  RPC/ TCP
                         ctxsw       UNIX         UDP         TCP conn
--------- ------------- ----- ----- ---- ----- ----- ----- ----- ----
stp2-001  Linux 2.6.10- 8.260  38.1 25.7  63.3  48.1  66.6  75.4 74.9
stp2-001  Linux 2.6.10- 8.090  46.2 26.0  63.4  55.5  45.9  63.6 73.5
stp2-001  Linux 2.6.10- 8.210  39.0 21.2  63.1  55.4  58.8  63.8 73.5
stp2-001  Linux 2.6.10- 2.850  46.5 26.0  64.8  54.6  45.5  74.0 73.6
stp2-001  Linux 2.6.10- 8.200  42.9 21.5  64.9  55.6  62.4  64.1 73.5
