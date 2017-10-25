From: peng yu <yupeng0921@gmail.com>
Subject: [iproute PATCH] ss: add detail explains of -m, -o, -e and -i options
 in ss man page
Date: Tue, 24 Oct 2017 17:13:30 -0700
Message-ID: <CAG3TDc0XxtkA5TU_GDzdZv1ujuqf09e9kBYQm2p5QGbppt7efw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: stephen@networkplumber.org, phil@nwl.cc
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:48894 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751591AbdJYANb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 20:13:31 -0400
Received: by mail-it0-f52.google.com with SMTP id c3so12111234itc.3
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 17:13:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 340a45f79395144bd14fdf9be1904c0036456b6e
Author: yupeng <yupeng0921@gmail.com>
Date:   Tue Oct 24 23:55:29 2017 +0000

    add additional explain in ss man page

    Add detail explains of -m, -o, -e and -i options, which are not
documented anywhere

    Signed-off-by: Peng Yu <yupeng0921@gmail.com>

diff --git a/man/man8/ss.8 b/man/man8/ss.8
index 3bec97f..4597733 100644
--- a/man/man8/ss.8
+++ b/man/man8/ss.8
@@ -176,6 +176,147 @@ states except for
 - opposite to
 .B bucket

+.SH Additional explain of -m, -o, -e and -i options
+Some fields may have different meanings if the netowrk protocl is
different. Below explain focus on tcp protocol.
+.TP
+.B -m option
+skmem:(r<rmem_alloc>,rb<rcv_buf>,t<wmem_alloc>,tb<snd_buf>,f<fwd_alloc>,w<wmem_queued>,o<opt_mem>,bl<back_log>)
+
+.B <rmem_alloc>
+the memory allocated for receiving package
+
+.B <rcv_buf>
+the total memory can be allocated for receiving package
+
+.B <wmem_alloc>
+the memory used for sending package (which has been sent to layer 3)
+
+.B <snd_buf>
+the total memory can be allocated for sending package
+
+.B <fwd_alloc>
+the memory allocated by the socket as cache, but not used for
receiving/sending pacakge yet. If need memory to send/receive package,
the memory in this cache will be used before allocate additional
memory.
+
+.B <wmem_queued>
+The memory allocated for sending package (which has not been sent to layer 3)
+
+.B <opt_mem>
+The memory used for storing socket option, e.g., the key for TCP MD5 signature
+
+.B <back_log>
+The memory used for the sk backlog queue. On a process context, if
the process is receving package, and a new package is received, it
will be put into the sk backlog queue, so it can be received by the
process immediately
+.TP
+.B -o option
+timer:(<timer_name>,<expire_time>,<retrans>)
+
+.B <timer_name>
+the name of the timer, there are five kind of timer names:
+
+.BR on ": means one of these timers: tcp retrans timer, tcp early
retrans timer and tail loss probe timer"
+
+.BR keepalive ": tcp keep alive timer"
+
+.BR timewait ": timewait stage timer"
+
+.BR persist ": zero window probe timer"
+
+.BR unknown ": none of the above timers"
+
+.B <expire_time>
+how long time the timer will expire
+
+.B <retrans>
+how many times the retran occurs
+.TP
+
+.B -e option
+uid:<uid_number> ino:<inode_number> sk:<cookie>
+
+.B <uid_number>
+the user id the socket belongs to
+
+.B <inode_number>
+the socket's inode number in VFS
+
+.B <cookie>
+an uuid of the socket
+
+.TP
+.B -i option
+show tcp internal information
+
+.B ts
+show string "ts" if the timestamp option is set
+
+.B sack
+show string "sack" if the sack option is set
+
+.B ecn
+show string "ecn" if the explicit congestion notification option is set
+
+.B ecnseen
+show string "ecnseen" if the saw ecn flag is found in received packages
+
+.B fastopen
+show string "fastopen" if the fastopen option is set
+
+.B cong_alg
+the congestion algorithm name, the default congestion algorithm is "cubic"
+
+.B wscale:<snd_wscale>:<rcv_wscale>
+if window scale option is used, this field shows the send scale
factory and receive scale factory
+
+.B rto:<icsk_rto>
+tcp retransmission timeout value, the unit is millisecond
+
+.B backoff:<icsk_backoff>
+used for exponential backoff retransmission, the actual
retransmission timeout vaule is icsk_rto << icsk_backoff
+
+.B rtt:<rtt>/<rttvar>
+rtt is the average round trip time, rttvar is the mean deviation of
rtt, their units are millisecond
+
+.B ato:<ato>
+ack timeout, unit is millisecond, used for delay ack mode
+
+.B mss:<mss>
+max segment size
+
+.B cwnd:<cwnd>
+congestion window size
+
+.B ssthresh:<ssthresh>
+tcp congestion window slow start threshold
+
+.B bytes_acked:<bytes_acked>
+bytes acked
+
+.B bytes_received:<bytes_received>
+bytes received
+
+.B segs_out:<segs_out>
+segments sent out
+
+.B segs_in:<segs_in>
+segments received
+
+.B send <send_bps>bps
+egress bps
+
+.B lastsnd:<lastsnd>
+how long time since the last package sent, the unit is millisecond
+
+.B lastrcv:<lastrcv>
+how long time since the last package received, the unit is millisecond
+
+.B lastack:<lastack>
+how long time since the last ack received, the unit is millisecond
+
+.B pacing_rate <pacing_rate>bps/<max_pacing_rate>bps
+the pacing rate and max pacing rate
+
+.B rcv_space:<rcv_space>
+a helper variable for TCP internal auto tunning socket receive buffer
+
 .SH USAGE EXAMPLES
 .TP
 .B ss -t -a
