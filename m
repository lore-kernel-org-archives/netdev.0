From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] tcp: efficient port randomisation (revised)
Date: Thu, 2 Dec 2004 13:49:30 -0800
Message-ID: <20041202134930.132d7bd8@dxpl.pdx.osdl.net>
References: <20041027092531.78fe438c@guest-251-240.pdx.osdl.net>
	<200411020854.44745.michael.vittrup.larsen@ericsson.com>
	<20041104100104.570e67cd@dxpl.pdx.osdl.net>
	<200411051103.59032.michael.vittrup.larsen@ericsson.com>
	<20041117153025.160eaa04@zqx3.pdx.osdl.net>
	<20041130214643.7b72300e.davem@davemloft.net>
	<20041201152446.3a0d5ce3@dxpl.pdx.osdl.net>
	<20041201204622.7b760400.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: michael.vittrup.larsen@ericsson.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041201204622.7b760400.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 1 Dec 2004 20:46:22 -0800
"David S. Miller" <davem@davemloft.net> wrote:


> I'm more interested in simply things like "lat_connect"
> from lmbench run over loopback.

Oh, that was easy using OSDL PLM/STP which gives an easy way to run
local tests.  

Baseline...
[STP 299123] lmbench_long results  Kernel: patch-2.6.10-rc2 PLM # 3869
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
-----------------
Patched...
[STP 299118] lmbench_long results  Kernel: tcp-port-randomization-2 PLM # 3907
*Local* Communication latencies in microseconds - smaller is better
-------------------------------------------------------------------
Host                 OS 2p/0K  Pipe AF     UDP  RPC/   TCP  RPC/ TCP
                        ctxsw       UNIX         UDP         TCP conn
--------- ------------- ----- ----- ---- ----- ----- ----- ----- ----
stp2-001  Linux 2.6.10- 2.770  46.3 25.0  64.4  49.5  44.3  75.2 75.6
stp2-001  Linux 2.6.10- 2.780  44.1 21.2  63.5  55.6  45.3  63.5 75.2
stp2-001  Linux 2.6.10- 2.790  47.5 24.8  40.4  48.5  45.5  63.7 76.9
stp2-001  Linux 2.6.10- 8.330  47.5 24.8  40.7  55.6  44.6  63.8 75.1
stp2-001  Linux 2.6.10- 8.150  47.9 25.7  41.2  49.6  45.2  72.7 75.1


These are run on a relatively slow machine (2 way Pentium III 850Mhz)
and it looks like the results are no change (in the noise).
