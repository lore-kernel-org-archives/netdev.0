From: Andi Kleen <ak@suse.de>
Subject: Re: Current 2.6.x TSO state
Date: Fri, 1 Oct 2004 12:11:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041001121123.19511403.ak@suse.de>
References: <20040930213221.06a3f5b3.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jheffner@psc.edu, herbert@gondor.apana.org.au
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040930213221.06a3f5b3.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 30 Sep 2004 21:32:21 -0700
"David S. Miller" <davem@davemloft.net> wrote:


> 
> 1) Andi sees performance anomaly to 2.6.5 kernels.
>    Hopefully fixed by diff3 above, merely awaiting
>    retesting by him.

Didn't fix the problem unfortunately, it's even a bit slower
with TSO  than the previous kernel I tested.

The stretch acks are still quite visible, see 
http://www.firstfloor.org/~andi/tso-stretch-ack1.gz for the full
log.

I will try to do the ACK instrumentation on the receiver you suggested 
later, unfortunately have some other urgent things to do first.

Do you want me to play with the new sysctl too?

tcptrace output for the last run as overview:

      complete conn: yes
        first packet:  Fri Oct  1 12:02:39.725840 2004
        last packet:   Fri Oct  1 12:02:49.729142 2004
        elapsed time:  0:00:10.003302
        total packets: 315102
        filename:      /tmp/LOG
   e->f:                              f->e:
     total packets:        298495           total packets:         16607      
     ack pkts sent:        298494           ack pkts sent:         16607      
     pure acks sent:            2           pure acks sent:        16605      
     unique bytes sent: 432215424           unique bytes sent:         0      
     actual data pkts:     298492           actual data pkts:          0      
     actual data bytes: 432215424           actual data bytes:         0      
     rexmt data pkts:           0           rexmt data pkts:           0      
     rexmt data bytes:          0           rexmt data bytes:          0      
     outoforder pkts:           0           outoforder pkts:           0      
     pushed data pkts:      16715           pushed data pkts:          0      
     SYN/FIN pkts sent:       1/1           SYN/FIN pkts sent:       1/1      
     req 1323 ws/ts:          Y/Y           req 1323 ws/ts:          Y/Y      
     adv wind scale:            2           adv wind scale:            0      
     req sack:                  Y           req sack:                  Y      
     sacks sent:                0           sacks sent:                0      
     mss requested:          1460 bytes     mss requested:          1460 bytes
     max segm size:          1448 bytes     max segm size:             0 bytes
     min segm size:           456 bytes     min segm size:             0 bytes
     avg segm size:          1447 bytes     avg segm size:             0 bytes
     max win adv:            5840 bytes     max win adv:           63712 bytes
     min win adv:            5840 bytes     min win adv:            5792 bytes
     zero win adv:              0 times     zero win adv:              0 times
     avg win adv:            5840 bytes     avg win adv:           63673 bytes
     initial window:         4344 bytes     initial window:            0 bytes
     initial window:            3 pkts      initial window:            0 pkts 
     ttl stream length: 432215424 bytes     ttl stream length:         0 bytes
     missed data:               0 bytes     missed data:               0 bytes
     truncated data:    423260664 bytes     truncated data:            0 bytes
     truncated packets:    298492 pkts      truncated packets:         0 pkts 
     data xmit time:       10.003 secs      data xmit time:        0.000 secs 
     idletime max:            8.4 ms        idletime max:            8.6 ms   
     throughput:         43207275 Bps       throughput:                0 Bps  


No SACKs etc. 

-Andi
