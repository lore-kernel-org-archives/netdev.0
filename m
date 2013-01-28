From: Leandro Lucarella <leandro.lucarella@sociomantic.com>
Subject: Re: Doubts about listen backlog and tcp_max_syn_backlog
Date: Mon, 28 Jan 2013 14:08:39 +0100
Message-ID: <20130128130839.GO4608@sociomantic.com>
References: <20130122184245.GJ4608@sociomantic.com>
 <50FF0C25.9000300@hp.com>
 <20130123104736.GK4608@sociomantic.com>
 <510039C8.7040401@hp.com>
 <20130124122223.GQ4608@sociomantic.com>
 <51018110.1070403@hp.com>
 <20130124192125.GD4608@sociomantic.com>
 <5102225E.2040506@gmail.com>
 <20130125100525.GE4608@sociomantic.com>
 <5105E6F2.2010805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rick Jones <rick.jones2@hp.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nivedita Singhvi <niveditasinghvi@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5105E6F2.2010805@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 27, 2013 at 06:48:18PM -0800, Nivedita Singhvi wrote:
[snip]
> > Thanks, but what about this?
> > 
> > pc2 $ nstat -z | grep -i drop
> > TcpExtLockDroppedIcmps          0                  0.0
> > TcpExtListenDrops               0                  0.0
> > TcpExtTCPPrequeueDropped        0                  0.0
> > TcpExtTCPBacklogDrop            0                  0.0
> > TcpExtTCPMinTTLDrop             0                  0.0
> > TcpExtTCPDeferAcceptDrop        0                  0.0
> 
> That seems bogus. 
> 
> 
> > pc2 $ netstat -s | grep -i drop
> >     470 outgoing packets dropped
> >     5659740 SYNs to LISTEN sockets dropped
> > 
> > Is this normal?
> 
> That's a lot ofconnect requests dropped, but it depends on how 
> long you've been up and how much traffic you've seen. 
> 
> Hmm...you were on an older Ubuntu, right? The netstat source 
> was patched to translate it as follows:
> 
> +    { "ListenDrops", N_("%u SYNs to LISTEN sockets dropped"), opt_number },
> 
> (see the file debian/patches/CVS-20081003-statistics.c_sync.patch 
>  in the net-tools src)

I have ubuntu 11.10 in all the servers I'm checking except for one with
12.04. Is weird, for the same ubuntu version (same kernel, same netstat,
same nstat) I get different outputs. Some have some counters that
coincide, some have more counters than other, some have different
counters than other...

pc121 # nstat -z | grep -i drop
TcpExtLockDroppedIcmps          0                  0.0
TcpExtListenDrops               0                  0.0
TcpExtTCPPrequeueDropped        0                  0.0
TcpExtTCPBacklogDrop            0                  0.0
TcpExtTCPMinTTLDrop             0                  0.0
TcpExtTCPDeferAcceptDrop        0                  0.0
pc121 # netstat -s | grep -i drop
    470 outgoing packets dropped
    5659762 SYNs to LISTEN sockets dropped

Other are like this:
pc126 # nstat -z | grep -i drop
TcpExtLockDroppedIcmps          0                  0.0
TcpExtListenDrops               2968982            0.0
TcpExtTCPPrequeueDropped        0                  0.0
TcpExtTCPBacklogDrop            0                  0.0
TcpExtTCPMinTTLDrop             0                  0.0
TcpExtTCPDeferAcceptDrop        0                  0.0
pc126 # netstat -s | grep -i drop
    2968982 SYNs to LISTEN sockets dropped

Other like this:
pc127 # nstat -z | grep -i drop
TcpExtLockDroppedIcmps          0                  0.0
TcpExtListenDrops               0                  0.0
TcpExtTCPPrequeueDropped        0                  0.0
TcpExtTCPBacklogDrop            0                  0.0
TcpExtTCPMinTTLDrop             0                  0.0
TcpExtTCPDeferAcceptDrop        0                  0.0
pc127 # netstat -s | grep -i drop
    1321958 SYNs to LISTEN sockets dropped


pc128 # nstat -z | grep -i drop
TcpExtLockDroppedIcmps          0                  0.0
TcpExtListenDrops               6455507            0.0
TcpExtTCPPrequeueDropped        0                  0.0
TcpExtTCPBacklogDrop            0                  0.0
TcpExtTCPMinTTLDrop             0                  0.0
TcpExtTCPDeferAcceptDrop        0                  0.0
pc128 # netstat -s | grep -i drop
    6 ICMP packets dropped because they were out-of-window
    6455507 SYNs to LISTEN sockets dropped

pc130 # nstat -z | grep -i drop
TcpExtLockDroppedIcmps          0                  0.0
TcpExtListenDrops               0                  0.0
TcpExtTCPPrequeueDropped        0                  0.0
TcpExtTCPBacklogDrop            0                  0.0
TcpExtTCPMinTTLDrop             0                  0.0
TcpExtTCPDeferAcceptDrop        0                  0.0
pc130 # netstat -s | grep -i drop
    3 ICMP packets dropped because they were out-of-window
    6728909 SYNs to LISTEN sockets dropped

And this is for the one with Ubuntu 12.04:
pc106 # nstat -z | grep -i drop
TcpExtLockDroppedIcmps          0                  0.0
TcpExtListenDrops               2598140            0.0
TcpExtTCPPrequeueDropped        0                  0.0
TcpExtTCPBacklogDrop            1711               0.0
TcpExtTCPMinTTLDrop             0                  0.0
TcpExtTCPDeferAcceptDrop        0                  0.0
TcpExtTCPReqQFullDrop           0                  0.0
pc106 # netstat -s | grep -i drop
    2598140 SYNs to LISTEN sockets dropped
    TCPBacklogDrop: 1711

Are this counters hardware-dependant? Or there anything else why they
might be different in different servers?

> i.e., the netstat pkg iS printing the value of the TCPEXT MIB counter
> that's counting TCPExtListenDrops. 

Then why nstat show that counter in 0 and netstat with what I assume is
the right value?

> Theoretically, that number should be the same as that printed by nstat,
> as they are getting it from the same kernel stats counter. I have not
> looked at nstat code (I actually almost always dump the counters from
> /proc/net/{netstat + snmp} via a simple prettyprint script (will send
> you that offline).  

Mmm, ok, thanks!

> If the nstat and netstat counters don't match, something is fishy.
> That nstat output is broken.  

I using the one from iproute package 20110315-1build1 (except for the
one with Ubuntu 12.04, which have 20111117-1ubuntu2). Any ideas on what
could be wrong?

> > And I don't know how could I narrow down the drops in any way. What I
> > know is capturing traffic with tcpdump, I see some packets leaving one
> > server but never arriving to the new one.

About this, tcpdump should get all the packets received by the NIC,
before the kernel have any chance to drop anything, right?

> Hmm..do you have a switch between your two end points dropping pkts? 

I have no idea, I assume there is because the server have only one NIC
and they are interconnected to several other servers, so there should be
something in the middle, but we have the servers offsite, I can't do any
sniffing myself in the middle of the endpoints.

> Could be.. Basically, by looking at the statistics kept by each layer, you 
> should be able to narrow it down a little bit at least. 

You mean statistics provided by the switch?

> It does still sound like some drops are occurring in TCP due to accept 
> backlog being full and you're overrunning TCP incoming processing (or 
> at least this contributing), going by that ListenDrops count. 

If that's so, then I guess you're implying tcpdump don't get the packets
before the kernel can drop them.

> Sorry, I'm on the road, travelling, and likely not online much this week. 

No worries! Thanks for the help, is very much appreciated.

-- 
Leandro Lucarella
sociomantic labs GmbH
http://www.sociomantic.com
