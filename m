From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: anyone ever done multicast AF_UNIX sockets?
Date: Mon, 03 Mar 2003 16:32:56 -0500
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3E63CA08.4040209@nortelnetworks.com>
References: <3E6399F1.10303@nortelnetworks.com>	<20030303.095641.87696857.davem@redhat.com>	<3E63A8CB.2090307@nortelnetworks.com> 	<20030303.105646.02089773.davem@redhat.com> <1046720532.28127.213.camel@eggis1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Terje Eggestad <terje.eggestad@scali.com>
List-Id: netdev.vger.kernel.org

Terje Eggestad wrote:
> On Mon, 2003-03-03 at 19:56, David S. Miller wrote:

>     TCP bandwidth is slightly faster than AF_UNIX bandwidth on my
>     sparc64 boxes for example.
> 
> I've seen that their are the same on linux.I tried to to do AF_UNIX
> instead of AF_INET internally to boost perf, but to no avail. Makes you
> suspect that the loopback device actually create an AF_UNIX connection
> under the hood ;-)

On my P4 1.8GHz, AF_INET vs AF_UNIX looks like this:


*Local* Communication latencies in microseconds - smaller is better
-------------------------------------------------------------
Host           OS 2p/0K  Pipe AF     UDP  RPC/   TCP  RPC/ TCP
                   ctxsw       UNIX         UDP         TCP conn
--------- ------- ----- ----- ---- ----- ----- ----- ----- ----
pcard0ks. 2.4.18- 1.740  10.4 15.9  20.1  33.1  23.5  44.3 72.7
pcard0ks. 2.4.18- 1.560  10.6 16.0  23.4  38.1  36.1  44.6 77.4


*Local* Communication bandwidths in MB/s - bigger is better
-----------------------------------------------------------
Host          OS  Pipe AF    TCP  File   Mmap  Bcopy  Bcopy  Mem   Mem
                        UNIX      reread reread (libc) (hand) read write
--------- ------- ---- ---- ---- ------ ------ ------ ------ ---- -----
pcard0ks. 2.4.18- 650. 677. 151.  721.9  958.0  290.8  288.8 955. 418.4
pcard0ks. 2.4.18- 379. 701. 163.  714.8  949.5  289.5  288.5 956. 420.5


On this machine at least, UDP latency is 25% worse than AF_UNIX, and TCP 
bandwidth is about 22% that of AF_UNIX.

Chris

-- 
Chris Friesen                    | MailStop: 043/33/F10
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com

