From: Rick Jones <rick.jones2@hp.com>
Subject: Re: on the wire behaviour of TSO on/off is supposed to be the same
 yes?
Date: Fri, 21 Jan 2005 12:18:53 -0800
Message-ID: <41F163AD.5070400@hp.com>
References: <41F1516D.5010101@hp.com> <200501211358.53783.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <200501211358.53783.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Mason wrote:
> The benefit of TSO is not throughput, but CPU utilization.  Throughput 
> increase is usually a side effect because of better PCI DMA behavior (eg. 
> large PCI transfers are better). 

I'm not looking for a throughput increase, the systems involved are already 
capable of link-rate without TSO, just looking for throughput to not drop with 
TSO.  If it were a throughput drop because the NIC CPU (bletch) saturated that 
would be one thing (such as happened with Tigon2 in another context) but this 
drop stems from what appears to be not filling cwnd and getting acks delayed by 
a timer.

> Are you seeing a CPU utilization decrease?

Yes, at the cost of occasional pauses in the data stream.

TSO is on
TCP STREAM TEST to 192.168.13.1
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   us/KB

131072 262142 262142    10.00       843.86   12.77    -1.00    2.480   -1.000
TSO is off
TCP STREAM TEST to 192.168.13.1
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   us/KB

131072 262142 262142    10.00       941.13   22.82    -1.00    3.972   -1.000

This is with tcp_tso_win_divisor set to 1 so TSO kicks-in before 200some-oddK 
are transfered.   The service demand drop (modulo the accuracy of CPU util 
measurements via the -DUSE_PROC_STAT stuff) is rather nice.

rick jones
subscribed, so mail to netdev will reach me - no need for separate cc
