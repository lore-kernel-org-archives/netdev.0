From: yupeng <yupeng0921@gmail.com>
Subject: [PATCH] add additional explain in ss man page
Date: Thu, 26 Oct 2017 07:15:31 +0000
Message-ID: <1509002131-22251-1-git-send-email-yupeng0921@gmail.com>
References: <20171025215221.GT32305@orbyte.nwl.cc>
Cc: phil@nwl.cc, mrv@mojatatu.com, stephen@networkplumber.org,
        yupeng <yupeng0921@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:45450 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750997AbdJZHPq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 03:15:46 -0400
Received: by mail-pg0-f65.google.com with SMTP id b192so2007151pga.2
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 00:15:46 -0700 (PDT)
In-Reply-To: <20171025215221.GT32305@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add detail explains of -m, -o, -e and -i options, which are not documented anywhere

Signed-off-by: yupeng <yupeng0921@gmail.com>
---
 man/man8/ss.8 | 185 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 181 insertions(+), 4 deletions(-)

diff --git a/man/man8/ss.8 b/man/man8/ss.8
index 3bec97f..8565ccb 100644
--- a/man/man8/ss.8
+++ b/man/man8/ss.8
@@ -37,19 +37,196 @@ Display both listening and non-listening (for TCP this means established connect
 Display only listening sockets (these are omitted by default).
 .TP
 .B \-o, \-\-options
-Show timer information.
+Show timer information. For tcp protocol, the output format is:
+.RS
+.P
+timer:(<timer_name>,<expire_time>,<retrans>)
+.P
+.TP
+.B <timer_name>
+the name of the timer, there are five kind of timer names:
+.RS
+.P
+.BR on ": means one of these timers: tcp retrans timer, tcp early retrans timer and tail loss probe timer"
+.P
+.BR keepalive ": tcp keep alive timer"
+.P
+.BR timewait ": timewait stage timer"
+.P
+.BR persist ": zero window probe timer"
+.P
+.BR unknown ": none of the above timers"
+.RE
+.TP
+.B <expire_time>
+how long time the timer will expire
+.P
+.TP
+.B <retrans>
+how many times the retran occurs
+.RE
 .TP
 .B \-e, \-\-extended
-Show detailed socket information
+Show detailed socket information. The output format is:
+.RS
+.P
+uid:<uid_number> ino:<inode_number> sk:<cookie>
+.P
+.TP
+.B <uid_number>
+the user id the socket belongs to
+.P
+.TP
+.B <inode_number>
+the socket's inode number in VFS
+.P
+.TP
+.B <cookie>
+an uuid of the socket
+.RE
 .TP
 .B \-m, \-\-memory
-Show socket memory usage.
+Show socket memory usage. The output format is:
+.RS
+.P
+skmem:(r<rmem_alloc>,rb<rcv_buf>,t<wmem_alloc>,tb<snd_buf>,f<fwd_alloc>,w<wmem_queued>,o<opt_mem>,bl<back_log>)
+.P
+.TP
+.B <rmem_alloc>
+the memory allocated for receiving packet
+.P
+.TP
+.B <rcv_buf>
+the total memory can be allocated for receiving packet
+.P
+.TP
+.B <wmem_alloc>
+the memory used for sending packet (which has been sent to layer 3)
+.P
+.TP
+.B <snd_buf>
+the total memory can be allocated for sending packet
+.P
+.TP
+.B <fwd_alloc>
+the memory allocated by the socket as cache, but not used for receiving/sending packet yet. If need memory to send/receive packet, the memory in this cache will be used before allocate additional memory.
+.P
+.TP
+.B <wmem_queued>
+The memory allocated for sending packet (which has not been sent to layer 3)
+.P
+.TP
+.B <opt_mem>
+The memory used for storing socket option, e.g., the key for TCP MD5 signature
+.P
+.TP
+.B <back_log>
+The memory used for the sk backlog queue. On a process context, if the process is receiving packet, and a new packet is received, it will be put into the sk backlog queue, so it can be received by the process immediately
+.RE
 .TP
 .B \-p, \-\-processes
 Show process using socket.
 .TP
 .B \-i, \-\-info
-Show internal TCP information.
+Show internal TCP information. Below fields may appear:
+.RS
+.P
+.TP
+.B ts
+show string "ts" if the timestamp option is set
+.P
+.TP
+.B sack
+show string "sack" if the sack option is set
+.P
+.TP
+.B ecn
+show string "ecn" if the explicit congestion notification option is set
+.P
+.TP
+.B ecnseen
+show string "ecnseen" if the saw ecn flag is found in received packets
+.P
+.TP
+.B fastopen
+show string "fastopen" if the fastopen option is set
+.P
+.TP
+.B cong_alg
+the congestion algorithm name, the default congestion algorithm is "cubic"
+.P
+.TP
+.B wscale:<snd_wscale>:<rcv_wscale>
+if window scale option is used, this field shows the send scale factory and receive scale factory
+.P
+.TP
+.B rto:<icsk_rto>
+tcp re-transmission timeout value, the unit is millisecond
+.P
+.TP
+.B backoff:<icsk_backoff>
+used for exponential backoff re-transmission, the actual re-transmission timeout value is icsk_rto << icsk_backoff
+.P
+.TP
+.B rtt:<rtt>/<rttvar>
+rtt is the average round trip time, rttvar is the mean deviation of rtt, their units are millisecond
+.P
+.TP
+.B ato:<ato>
+ack timeout, unit is millisecond, used for delay ack mode
+.P
+.TP
+.B mss:<mss>
+max segment size
+.P
+.TP
+.B cwnd:<cwnd>
+congestion window size
+.P
+.TP
+.B ssthresh:<ssthresh>
+tcp congestion window slow start threshold
+.P
+.TP
+.B bytes_acked:<bytes_acked>
+bytes acked
+.P
+.TP
+.B bytes_received:<bytes_received>
+bytes received
+.P
+.TP
+.B segs_out:<segs_out>
+segments sent out
+.P
+.TP
+.B segs_in:<segs_in>
+segments received
+.P
+.TP
+.B send <send_bps>bps
+egress bps
+.P
+.TP
+.B lastsnd:<lastsnd>
+how long time since the last packet sent, the unit is millisecond
+.P
+.TP
+.B lastrcv:<lastrcv>
+how long time since the last packet received, the unit is millisecond
+.P
+.TP
+.B lastack:<lastack>
+how long time since the last ack received, the unit is millisecond
+.P
+.TP
+.B pacing_rate <pacing_rate>bps/<max_pacing_rate>bps
+the pacing rate and max pacing rate
+.P
+.TP
+.B rcv_space:<rcv_space>
+a helper variable for TCP internal auto tuning socket receive buffer
+.RE
 .TP
 .B \-K, \-\-kill
 Attempts to forcibly close sockets. This option displays sockets that are
-- 
2.7.4
