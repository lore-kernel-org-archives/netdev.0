From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: Fwd: Re: [PATCH net-next 00/15] net/smc: Shared Memory Communications
 - RDMA
Date: Tue, 21 Jun 2016 16:02:59 +0200
Message-ID: <57694913.8040303@linux.vnet.ibm.com>
References: <1465486588-22421-1-git-send-email-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:20815 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751547AbcFUODL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 10:03:11 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5LDrrgW023102
	for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 10:03:04 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23n25wpgc0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 10:03:04 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Tue, 21 Jun 2016 15:03:02 +0100
In-Reply-To: <1465486588-22421-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

the SMC-R patches submitted 2016-06-03 show up in state "Changes 
Requested" on patchwork:
https://patchwork.ozlabs.org/project/netdev/list/?submitter=2266&state=*&page=1

You had requested a change of the SMC-R description in the cover letter. 
We came up with the response below. Do you need anything else from us?

Kind regards,
Ursula Braun

-------- Forwarded Message --------
Subject: Re: [PATCH net-next 00/15] net/smc: Shared Memory 
Communications - RDMA
Date: Thu,  9 Jun 2016 17:36:28 +0200
From: Ursula Braun <ubraun@linux.vnet.ibm.com>
To: davem@davemloft.net
CC: netdev@vger.kernel.org, linux-s390@vger.kernel.org, 
schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com

On Tue, 2016-06-07 at 15:07 -0700, David Miller wrote:
> In case my previous reply wasn't clear enough, I require that you provide
> a more accurate description of what the implications of this feature are.
>
> Namely, that important _CORE_ networking features are completely bypassed
> and unusable when SMC applies to a connection.
>
> Specifically, all packet shaping, filtering, traffic inspection, and
> flow management facilitites in the kernel will not be able to see nor
> act upon the data flow of these TCP connections once established.
>
> It is always important, and in my opinion required, to list the
> negative aspects of your change and not just the "wow, amazing"
> positive aspects.
>
> Thanks.
>
>
Correct, the SMC-R data stream bypasses TCP and thus cannot enjoy its
features. This is the price for leveraging the TCP application ecosystem
and reducing CPU load.

When a load balancer allows the TCP handshake to take place between a
worker node and the TCP client, RDMA will be used between these two
nodes. So anything based on TCP connection establishment (including a
firewall) can apply to SMC-R, too. To be clear -- yes, the data flow
later on is not subject to these features anymore.  At least VLAN
isolation from the TCP part can be leveraged for RDMA traffic. From our
experience, discussions, etc., that tradeoff seems acceptable in a
classical data center environment.

Improving our cover letter would result in the following new
introductory motivation part at the beginning and a slightly modified 
list of
planned enhancements at the end:

On Fri, 2016-06-03 at 17:26 +0200, Ursula Braun wrote:

> These patches are the initial part of the implementation of the
> "Shared Memory Communications-RDMA" (SMC-R) protocol. The protocol is
> defined in RFC7609 [1]. It allows transformation of TCP connections
> using the "Remote Direct Memory Access over Converged Ethernet" (RoCE)
> feature of specific communication hardware for data center environments.
>
> SMC-R inherits TCP qualities such as reliable connections, host-based
> firewall packet filtering (on connection establishment) and unmodified
> application of communication encryption such as TLS (transport layer
> security) or SSL (secure sockets layer). It is transparent to most existing
> TCP connection load balancers that are commonly used in the enterprise data
> center environment for multi-tier application workloads.
>
> Being designed for the data center network switched fabric environment, it
> does not need congestion control and thus reaches line speed right away
> without having to go through slow start as with TCP. This can be beneficial
> for short living flows including request response patterns requiring
> reliability. A full SMC-R implementation also provides seamless high
> availability and load-balancing demanded by enterprise installations.
>
> SMC-R does not require an RDMA communication manager (RDMA CM). Its use of
> RDMA provides CPU savings transparently for unmodified applications.
> For instance, when running 10 parallel connections with uperf, we measured
> a decrease of 60% in CPU consumption with SMC-R compared to TCP/IP
> (with throughput and latency comparable;
> measured on x86_64 with the same RoCE card and port).
>
These patches are the initial part of the implementation of the
"Shared Memory Communications-RDMA" (SMC-R) protocol as defined in
RFC7609 [1].  While SMC-R does not aim to replace TCP,
it taps a wealth of existing data center TCP socket applications
to become more efficient without the need for rewriting them.
SMC-R uses RDMA over Converged Ethernet (RoCE) to save CPU consumption.
For instance, when running 10 parallel connections with uperf, we measured
a decrease of 60% in CPU consumption with SMC-R compared to TCP/IP
(with throughput and latency comparable;
measured on x86_64 with the same RoCE card and port).

SMC-R does not require an RDMA communication manager (RDMA CM).

SMC-R inherits TCP qualities such as reliable connections, host-based
firewall packet filtering (on connection establishment) and unmodified
application of communication encryption such as TLS (transport layer
security) or SSL (secure sockets layer). Since original TCP is used to
establish SMC-R connections, load balancers and packet inspection based
on TCP/IP connection establishment continue to work for SMC-R.

On the other hand using SMC-R implies:
- either involving a preload library when invoking the unchanged 
TCP-application
   or slightly modifying the source by simply changing the socket family 
in the
   socket() call
- accepting extra overhead and latency in connection establishment due to
   SMC Connection Layer Control (CLC) handshake
- explicit coupling of RoCE ports with Ethernet ports
- not routable as currently built on RoCE V1
- bypassing of packet-based networking features
     - filtering (netfilter)
     - sniffing (libpcap, packet sockets, (E)BPF)
     - traffic control (scheduling, shaping)
- bypassing of IP-header based socket options
- bypassing of memory buffer (pressure) management
- unusable together with IPsec

>
> Overview of the SMC-R Protocol described in informational RFC 7609
>
> SMC-R is an open protocol that provides RDMA capabilities over RoCE
> transparently for applications exploiting TCP sockets.
> A new socket protocol family PF_SMC is introduced.
> There are no changes required to applications using the sockets API for TCP
> stream sockets other than the specification of the new socket family AF_SMC.
> Unmodified applications can be used by means of a dynamic preload shared
> library which rewrites the socket API call
> socket(AF_INET, SOCK_STREAM, IPPROTO_TCP) into
> socket(AF_SMC,  SOCK_STREAM, IPPROTO_TCP).
> SMC-R re-uses the address family AF_INET for all addressing purposes around
> struct sockaddr.
>
>
> SMC-R system architecture layers:
>
> +=============================================================================+
> |                                      | unmodified TCP application           |
> | native SMC application               +--------------------------------------+
> |                                      | dynamic preload shared library       |
> +=============================================================================+
> |                                 SMC socket                                  |
> +-----------------------------------------------------------------------------+
> |                    | TCP socket (for connection establishment and fallback) |
> | IB verbs           +--------------------------------------------------------+
> |                    | IP                                                     |
> +--------------------+--------------------------------------------------------+
> | RoCE device driver | some network device driver                             |
> +=============================================================================+
>
>
> Terms:
>
> A link group is determined by an ordered peer pair of TCP client and TCP server
> (IP addresses and subnet). Reversed client server roles cause an own link group.
> A link is a logical point-to-point connection based on an
> infiniband reliable connected queue pair (RC-QP) between two RoCE ports
> (MACs and GIDs) of a peer pair.
> A link group can have 1..8 links for failover and load balancing.
> This initial Linux implementation always has 1 link per link group.
> Each link group on a peer can have 1..255 remote memory buffers (RMBs).
> If more RMBs are needed, a peer can open another link group
> (this initial Linux implementation) or fall back to TCP.
> Each RMB has its own particular size and its own (R)DMA mapping and credentials
> (rtoken consisting of rkey and RDMA "virtual address").
> This initial Linux implementation uses physically contiguous memory for RMBs
> but we are working towards scattered memory because of memory fragmentation.
> Each RMB has 1..255 RMB elements (RMBEs) of equal size
> to provide multiplexing of connections within an RMB.
> An RMBE is the RDMA Write destination organized as wrapping ring buffer
> for data transmit of a particular connection in one direction
> (duplex by means of mirror symmetry as with TCP).
> This initial Linux implementation always has 1 RMBE per RMB
> and thus an individual RMB for each connection.
>
>
> SMC-R connection establishment with subsequent data transfer:
>
>    CLIENT                                                   SERVER
>
> TCP three-way handshake:
>                          regular TCP SYN
>       -------------------------------------------------------->
>                        regular TCP SYN ACK
>       <--------------------------------------------------------
>                          regular TCP ACK
>       -------------------------------------------------------->
>
> SMC Connection Layer Control (CLC) handshake
> exchanges RDMA credentials between peers:
>              via above TCP connection: SMC CLC Proposal
>       -------------------------------------------------------->
>               via above TCP connection: SMC CLC Accept
>       <--------------------------------------------------------
>              via above TCP connection: SMC CLC Confirm
>       -------------------------------------------------------->
>
> SMC Link Layer Control (LLC) (only once per link, i.e. 1st conn. of link group):
>                  RoCE RC-QP: SMC LLC Confirm Link
>       <========================================================
>              RoCE RC-QP: SMC LLC Confirm Link response
>       ========================================================>
>
> SMC data transmission (incl. SMC Connection Data Control (CDC) message):
>                        RoCE RC-QP: RDMA Write
>       ========================================================>
>              RoCE RC-QP: SMC CDC message (flow control)
>       ========================================================>
>                           ...
>
>                        RoCE RC-QP: RDMA Write
>       <========================================================
>              RoCE RC-QP: SMC CDC message (flow control)
>       <========================================================
>                           ...
>
>
> Data flow within an established connection:
>
> +----------------------------------------------------------------------------
> |            SENDER
> | sendmsg()
> |    |
> |    | produces into sndbuf [sender's process context]
> |    v
> | +--------+
> | | sndbuf | [ring buffer]
> | +--------+
> |    |
> |    | consumes from sndbuf and produces into receiver's RMBE [any context]
> |    | by sending RDMA Write followed by SMC CDC message over RoCE RC-QP
> |    |
> +----|-----------------------------------------------------------------------
>      |
> +----|-----------------------------------------------------------------------
> |    v       RECEIVER
> | +------+
> | | RMBE | [ring buffer, can have size different from sender's sndbuf]
> | |      | [RMBE represents rcvbuf, no further de-coupling as on sender side]
> | +------+
> |    |
> |    | consumes from RMBE [receiver's process context]
> |    v
> | recvmsg()
> +----------------------------------------------------------------------------
>
>
> Flow control ("cursor" updates) by means of SMC CDC messages:
>
>                SENDER                            RECEIVER
>
>         sends updates via CDC-------------+   sends updates via CDC
>         on consuming from sndbuf          |   on consuming from RMBE
>         and producing into RMBE           |   by means of recvmsg()
>                                           |            |
>                                           |            |
>       +-----------------------------------|------------+
>       |                                   |
>    +--v-------------------------+      +--v-----------------------+
>    | receiver's consumer cursor |      | sender's producer cursor----+
>    +----------------|-----------+      +--------------------------+  |
>                     |                                                |
>                     |                        receiver's RMBE         |
>                     |                  +--------------------------+  |
>                     |                  |                          |  |
>                     +--------------------------------+            |  |
>                                        |             |            |  |
>                                        |             v            |  |
>                                        |             +------------|  |
>                                        |-------------+////////////|  |
>                                        |//RDMA data written by////|  |
>                                        |////sender that is////////|  |
>                                        |/available to be consumed/|  |
>                                        |///////// +---------------|  |
>                                        |----------+^              |  |
>                                        |           |              |  |
>                                        |           +-----------------+
>                                        |                          |
>                                        +--------------------------+
>
> Sending updates of the producer cursor is immediate for low latency;
> something like Nagle's algorithm (absence of TCP_NODELAY) is optional and
> currently not part of this initial Linux implementation.
> Sending updates of the consumer cursor is conditional to avoid the
> silly window syndrome.
>
>
> Normal connection termination:
>
> Normal connection termination starts transitioning from socket state
> ACTIVE via either "Active Close" or "Passive Close".
>
> shutdown rdwr               +-----------------+
> or close,   +-------------->|  INIT / CLOSED  |<-------------+
> send PeerCon|nClosed        +-----------------+              | PeerConnClosed
>             |                       |                        | received
>             |            connection | established            |
>             |                       V                        |
>     +----------------+     +-----------------+     +----------------+
>     |AppFinCloseWait |     |     ACTIVE      |     |PeerFinCloseWait|
>     +----------------+     +-----------------+     +----------------+
>             |                   |         |                   |
>             |     Active Close: |         |Passive Close:     |
>             |     close or      |         |PeerConnClosed or  |
>             |     shutdown wr or|         |PeerDoneWriting    |
>             |     shutdown rdwr |         |received           |
>             |                   V         V                   |
>  PeerConnClo|sed    +--------------+   +-------------+        | close or
>  received   +--<----|PeerCloseWait1|   |AppCloseWait1|--->----+ shutdown rdwr,
>             |       +--------------+   +-------------+        | send
>             |  PeerDoneWri|ting                | shutdown wr, | PeerConnClosed
>             |  received   |            send Pee|rDoneWriting  |
>             |             V                    V              |
>             |       +--------------+   +-------------+        |
>             +--<----|PeerCloseWait2|   |AppCloseWait2|--->----+
>                     +--------------+   +-------------+
>
> In state CLOSED, the socket can be destructed only, once the application has
> issued a close().
>
> Abnormal connection termination:
>
>                             +-----------------+
>             +-------------->|  INIT / CLOSED  |<-------------+
>             |               +-----------------+              |
>             |                                                |
>             |           +-----------------------+            |
>             |           |     Any state         |            |
>  PeerConnAbo|rt         | (before setting       |            | send
>  received   |           |  PeerConnClosed       |            | PeerConnAbort
>             |           |  indicator in         |            |
>             |           |  peer's RMBE)         |            |
>             |           +-----------------------+            |
>             |                   |         |                  |
>             |     Active Abort: |         | Passive Abort:   |
>             |     problem,      |         | PeerConnAbort    |
>             |     send          |         | received,        |
>             |     PeerConnAbort,|         | ECONNRESET       |
>             |     ECONNABORTED  |         |                  |
>             |                   V         V                  |
>             |       +--------------+   +--------------+      |
>             +-------|PeerAbortWait |   | ProcessAbort |------+
>                     +--------------+   +--------------+
>
>
> Implementation notes beyond RFC 7609:
>
> A PNET table in sysfs provides the mapping between network device names and
> RoCE Infiniband device names for the transparent switch of data communication.
> A PNET table can contain an arbitrary number of PNETIDs.
> Each PNETID contains exactly one (Ethernet) network device name
> and one or more RoCE Infiniband device names.
> Each device name can only exist in at most one PNETID (no overlapping).
> This initial Linux implementation allows at most one RoCE Infiniband device
> name per PNETID.
> After a new TCP connection is established, the network device name
> used for egress traffic with the TCP connection's local source IP address
> is used as key to lookup the unique PNETID, and the RoCE Infiniband device
> of this PNETID is used to switch data communication from TCP to RDMA
> during SMC CLC handshake.
>
>
> Problem determination:
>
> A protocol dissector is available with upstream wireshark for formatting
> SMC-R related RoCE LAN traffic.
> [https://code.wireshark.org/review/gitweb?p=wireshark.git;a=blob;f=epan/dissectors/packet-smcr.c]
>
>
> We are working on enhancing the Linux implementation to cover:
>
> - Improve default socket closing asynchronicity
> - Address corner cases with many parallel connections
> - Load balancing and fail-over
> - Urgent data
> - Splice and sendpage support
> - Keepalive
> - More socket options
> - IPv6 support
> - Tracing
> - Statistics support
>
- Improve default socket closing asynchronicity
- Address corner cases with many parallel connections
- Tracing
- Integrated load balancing and fail-over within a link group
- Splice and sendpage support
- IPv6 addressing support
- Keepalive, Cork
- Namespaces support
- Urgent data
- More socket options
- Diagnostics
- Statistics support
- SNMP support

>
> References:
>
> [1] SMC-R Informational RFC: http://www.rfc-editor.org/info/rfc7609

Do you agree with this changed cover letter?

Kind regards,
Ursula Braun
