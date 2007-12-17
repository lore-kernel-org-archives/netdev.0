From: "James Nichols" <jamesnichols3@gmail.com>
Subject: Re: After many hours all outbound connections get stuck in SYN_SENT
Date: Mon, 17 Dec 2007 11:27:46 -0500
Message-ID: <83a51e120712170827g5542a2a0pead102e1bd55eccd@mail.gmail.com>
References: <83a51e120712160834r29112fb0xa1f61c35f180bf8f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.188]:44928 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756760AbXLQQ1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 11:27:48 -0500
Received: by mu-out-0910.google.com with SMTP id i10so2972567mue.5
        for <netdev@vger.kernel.org>; Mon, 17 Dec 2007 08:27:46 -0800 (PST)
In-Reply-To: <83a51e120712160834r29112fb0xa1f61c35f180bf8f@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is some additional information about this problem as requested.
I ran ss -m, but no data was returned, what options should I use with
ss to gather relevant information?

The output of netstat -s:

Ip:
    1346453452 total packets received
    0 forwarded
    0 incoming packets discarded
    1345744076 incoming packets delivered
    1338284375 requests sent out
    50 reassemblies required
    15 packets reassembled ok
    15 fragments received ok
    50 fragments created
Icmp:
    431 ICMP messages received
    0 input ICMP message failed.
    ICMP input histogram:
        destination unreachable: 42
        echo requests: 6
        echo replies: 377
        timestamp request: 2
        address mask request: 2
    747 ICMP messages sent
    0 ICMP messages failed
    ICMP output histogram:
        destination unreachable: 739
        echo replies: 6
        timestamp replies: 2
Tcp:
    13115640 active connections openings
    1291131 passive connection openings
    381803 failed connection attempts
    6445 connection resets received
    148 connections established
    1339571927 segments received
    1330375560 segments send out
    2443951 segments retransmited
    345 bad segments received.
    61292 resets sent
Udp:
    5608790 packets received
    725 packets to unknown port received.
    0 packet receive errors
    5609766 packets sent
TcpExt:
    1916 resets received for embryonic SYN_RECV sockets
    1290 packets pruned from receive queue because of socket buffer overrun
    1250631 TCP sockets finished time wait in fast timer
    43568 time wait sockets recycled by time stamp
    16323 active connections rejected because of time stamp
    262 packets rejects in established connections because of timestamp
    18505058 delayed acks sent
    3931 delayed acks further delayed because of locked socket
    Quick ack mode was activated 434830 times
    1902 times the listen queue of a socket overflowed
    1902 SYNs to LISTEN sockets ignored
    1068352581 packets directly queued to recvmsg prequeue.
    92424765 packets directly received from backlog
    800659035 packets directly received from prequeue
    1158417138 packets header predicted
    2223869 packets header predicted and directly queued to user
    22256941 acknowledgments not containing data received
    1109445014 predicted acknowledgments
    96 times recovered from packet loss due to fast retransmit
    325 times recovered from packet loss due to SACK data
    1 bad SACKs received
    Detected reordering 8 times using FACK
    Detected reordering 7 times using time stamp
    21 congestion windows fully recovered
    29 congestion windows partially recovered using Hoe heuristic
    452978 congestion windows recovered after partial ack
    97 TCP data loss events
    2269 timeouts after reno fast retransmit
    144 timeouts after SACK recovery
    12690 timeouts in loss state
    731 fast retransmits
    70 forward retransmits
    38188 retransmits in slow start
    959183 other TCP timeouts
    TCPRenoRecoveryFail: 67
    38 sack retransmits failed
    42 times receiver scheduled too late for direct processing
    75627 packets collapsed in receive queue due to low socket buffer
    6003 DSACKs sent for old packets
    13 DSACKs sent for out of order packets
    136 DSACKs received
    4038 connections reset due to unexpected data
    557 connections reset due to early user close
    319219 connections aborted due to timeout






On 12/16/07, James Nichols <jamesnichols3@gmail.com> wrote:
> Hello,
>
> I have a Java application that makes a large number of outbound
> webservice calls over HTTP/TCP.  The hosts contacted are a fixed set
> of about 2000 hosts and a web service call is made to each of them
> approximately every 5 mintues by a pool of 200 Java threads.  Over
> time, on average a percentage of these hosts are unreachable for one
> reason or another, usually because they are on wireless cell phone
> NICs, so there is a persistent count of sockets in the SYN_SENT state
> in the range of about 60-80.  This is fine, as these failed connection
> attempts eventually time out.
>
> However, after approximately 38 hours of operation, all outbound
> connection attempts get stuck in the SYN_SENT state.  It happens
> instantaneously, where I go from the baseline of about 60-80 sockets
> in SYN_SENT to a count of 200 (corresponding to the # of java threads
> that make these calls).
>
> When I stop and start the Java application, all the new outbound
> connections still get stuck in SYN_SENT state.  During this time, I am
> still able to SSH to the box and run wget to Google, cnn, etc, so the
> problem appears to be specific to the hosts that I'm accessing via the
> webservices.
>
> For a long time, the only thing that would resolve this was rebooting
> the entire machine.  Once I did this, the outbound connections could
> be made succesfully.  However, very recently when I had once of these
> incidents I disabled tcp_sack via:
>
> echo "0" > /proc/sys/net/ipv4/tcp_sack
>
> And the problem almost instanteaously resolved itself and outbound
> connection attempts were succesful.  I hadn't attempted this before
> because I assumed that if any of my network
> equipment or remote hosts had a problem with SACK, that it would never
> work.  In my case, it worked fine for about 38 hours before hitting a
> wall where no outbound connections could be made.
>
> I'm running kernel 2.6.18 on RedHat, but have had this problem occur
> on earlier kernel versions (all 2.4 and 2.6).  I know a lot of people
> will say it must be the firewall, but I've seen had this issue on
> different router vendors, firewall vendors, different co-location
> facilities, NICs, and several other variables.  I've totaly rebuilt
> every piece of the archtiecture at one time or another and still see
> this issue.  I've had this problem to varying degrees of severity for
> the past 4 years or so.  Up until this point, the only thing other
> than a complete machine restart that fixes the problem is disabling
> tcp_sack.  When I disable it, the problem goes away almost
> instantaneously.
>
> Is there a kernel buffer or some data structure that tcp_sack uses
> that gets filled up after an extended period of operation?
> How can I debug this problem in the kernel to find out what the root cause is?
>
> I emailed linux-kernel and they asked for output of netstat -s, I can
> get this the next
> time it occurs- any other usefull data to collect?
>
> I've temporarily signed up on this list, but may cancel signup if I can't
> handle the traffic, so please CC me directly on any replies.
>
> Thanks,
>
> James Nichols
>
