From: Elvis =?iso-8859-1?q?Pf=FCtzenreuter?= <epx@altoriopreto.com.br>
Subject: Problems with TCP + netem packet loss simulation
Date: Thu, 11 Nov 2004 21:15:23 -0200
Message-ID: <200411112115.23269.epx@altoriopreto.com.br>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I am experiencing a strange problem when I try to simulate a lossy channel 
with netem scheduler module. Whatever the packet loss %, all TCP connections 
eventually stall. 

The TCP connection exchange no packets after the stall (not even when the 
process is killed), but PING to the other host flows normally, with the 
expected loss rate.

The first thing to be suspected would be my throughput testing application, 
but other TCP connections (including ssh sessions) will stall too, more often 
if the packet loss is high.

I tried the kernels 2.6.9-rc4, 2.6.9, 2.6.10rc1 with the same results. Any 
other netem function (delay, reordering [2.6.10rc1] etc.) does not stall the 
TCP connection.

I suspected a bug in TCP stack (SCTP connections stall for 1 second sometimes 
but they recover and go on), but if I make packet loss with "nth" iptables 
rule, the connection does not stall. I even tried to pull network cables, 
turn off switch etc. to see if any "real" packet loss would stall TCP the 
same way but it it didn't happen.  

And, since I use packet loss-based techniques (tc ingress filter) to do QoS on 
my ADSL, I would have been experiencing problems with TCP well before I tried 
netem. So it seems to be some interation between TCP and netem. 

I am using 2 machines in a local Ethernet network. I didn't try to put netem 
in a third machine (that would be the router), to see if it improves 
something. I am going to try this later. But if anyone is aware of the cause 
of the problem I am experiencing, I'd like to hear of.

Thanks

-- 
Elvis
