From: peng yu <yupeng0921@gmail.com>
Subject: Re: [iproute PATCH] ss: add detail explains of -m, -o, -e and -i
 options in ss man page
Date: Wed, 25 Oct 2017 14:20:25 -0700
Message-ID: <CAG3TDc3_GGuKCz=2c-jTXutNq_rWcig3u5oB9XEyrsK0_yEbTg@mail.gmail.com>
References: <CAG3TDc0XxtkA5TU_GDzdZv1ujuqf09e9kBYQm2p5QGbppt7efw@mail.gmail.com>
 <8560b3clnj.fsf@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org, stephen@networkplumber.org, phil@nwl.cc
To: Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:54793 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751668AbdJYVU0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 17:20:26 -0400
Received: by mail-it0-f45.google.com with SMTP id 72so2680769itk.3
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 14:20:26 -0700 (PDT)
In-Reply-To: <8560b3clnj.fsf@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for your suggestion, below is a new patch. What I did:
1. change all 'package' to 'packet'
2. put my additional text as second paragraphs of the original options.
3. checked the man page by aspell
If anything else need to fix, please let me know.


commit 9803d27de31028733de789495d78ff7a39385009
Author: yupeng <yupeng0921@gmail.com>
Date:   Wed Oct 25 21:12:21 2017 +0000

    add additional explain in ss man page

    Add detail explains of -m, -o, -e and -i options, which are not
    documented anywhere

    Signed-off-by: Peng Yu <yupeng0921@gmail.com>

diff --git a/man/man8/ss.8 b/man/man8/ss.8
index 3bec97f..401ae3e 100644
--- a/man/man8/ss.8
+++ b/man/man8/ss.8
@@ -37,19 +37,152 @@ Display both listening and non-listening (for TCP
this means established connect
 Display only listening sockets (these are omitted by default).
 .TP
 .B \-o, \-\-options
-Show timer information.
+Show timer information. For tcp protocol, the output format is:
+.br
+timer:(<timer_name>,<expire_time>,<retrans>)
+.br
+.B <timer_name>
+the name of the timer, there are five kind of timer names:
+.RS
+.RS
+.BR on ": means one of these timers: tcp retrans timer, tcp early
retrans timer and tail loss probe timer"
+.br
+.BR keepalive ": tcp keep alive timer"
+.br
+.BR timewait ": timewait stage timer"
+.br
+.BR persist ": zero window probe timer"
+.br
+.BR unknown ": none of the above timers"
+.RE
+.B <expire_time>
+how long time the timer will expire
+.br
+.B <retrans>
+how many times the retran occurs
+.RE
 .TP
 .B \-e, \-\-extended
-Show detailed socket information
+Show detailed socket information. The output format is:
+.br
+uid:<uid_number> ino:<inode_number> sk:<cookie>
+.br
+.B <uid_number>
+the user id the socket belongs to
+.br
+.B <inode_number>
+the socket's inode number in VFS
+.br
+.B <cookie>
+an uuid of the socket
+
 .TP
 .B \-m, \-\-memory
-Show socket memory usage.
+Show socket memory usage. The output format is:
+.br
+skmem:(r<rmem_alloc>,rb<rcv_buf>,t<wmem_alloc>,tb<snd_buf>,f<fwd_alloc>,w<wmem_queued>,o<opt_mem>,bl<back_log>)
+.B <rmem_alloc>
+the memory allocated for receiving packet
+.br
+.B <rcv_buf>
+the total memory can be allocated for receiving packet
+.br
+.B <wmem_alloc>
+the memory used for sending packet (which has been sent to layer 3)
+.br
+.B <snd_buf>
+the total memory can be allocated for sending packet
+.br
+.B <fwd_alloc>
+the memory allocated by the socket as cache, but not used for
receiving/sending packet yet. If need memory to send/receive packet,
the memory in this cache will be used before allocate additional
memory.
+.br
+.B <wmem_queued>
+The memory allocated for sending packet (which has not been sent to layer 3)
+.br
+.B <opt_mem>
+The memory used for storing socket option, e.g., the key for TCP MD5 signature
+.br
+.B <back_log>
+The memory used for the sk backlog queue. On a process context, if
the process is receiving packet, and a new packet is received, it will
be put into the sk backlog queue, so it can be received by the process
immediately
 .TP
 .B \-p, \-\-processes
 Show process using socket.
 .TP
 .B \-i, \-\-info
-Show internal TCP information.
+Show internal TCP information. Below fields may appear:
+.br
+.B ts
+show string "ts" if the timestamp option is set
+.br
+.B sack
+show string "sack" if the sack option is set
+.br
+.B ecn
+show string "ecn" if the explicit congestion notification option is set
+.br
+.B ecnseen
+show string "ecnseen" if the saw ecn flag is found in received packets
+.br
+.B fastopen
+show string "fastopen" if the fastopen option is set
+.br
+.B cong_alg
+the congestion algorithm name, the default congestion algorithm is "cubic"
+.br
+.B wscale:<snd_wscale>:<rcv_wscale>
+if window scale option is used, this field shows the send scale
factory and receive scale factory
+.br
+.B rto:<icsk_rto>
+tcp re-transmission timeout value, the unit is millisecond
+.br
+.B backoff:<icsk_backoff>
+used for exponential backoff re-transmission, the actual
re-transmission timeout value is icsk_rto << icsk_backoff
+.br
+.B rtt:<rtt>/<rttvar>
+rtt is the average round trip time, rttvar is the mean deviation of
rtt, their units are millisecond
+.br
+.B ato:<ato>
+ack timeout, unit is millisecond, used for delay ack mode
+.br
+.B mss:<mss>
+max segment size
+.br
+.B cwnd:<cwnd>
+congestion window size
+.br
+.B ssthresh:<ssthresh>
+tcp congestion window slow start threshold
+.br
+.B bytes_acked:<bytes_acked>
+bytes acked
+.br
+.B bytes_received:<bytes_received>
+bytes received
+.br
+.B segs_out:<segs_out>
+segments sent out
+.br
+.B segs_in:<segs_in>
+segments received
+.br
+.B send <send_bps>bps
+egress bps
+.br
+.B lastsnd:<lastsnd>
+how long time since the last packet sent, the unit is millisecond
+.br
+.B lastrcv:<lastrcv>
+how long time since the last packet received, the unit is millisecond
+.br
+.B lastack:<lastack>
+how long time since the last ack received, the unit is millisecond
+.br
+.B pacing_rate <pacing_rate>bps/<max_pacing_rate>bps
+the pacing rate and max pacing rate
+.br
+.B rcv_space:<rcv_space>
+a helper variable for TCP internal auto tuning socket receive buffer
+
 .TP
 .B \-K, \-\-kill
 Attempts to forcibly close sockets. This option displays sockets that are

2017-10-25 8:06 GMT-07:00 Roman Mashak <mrv@mojatatu.com>:
> peng yu <yupeng0921@gmail.com> writes:
>
>> commit 340a45f79395144bd14fdf9be1904c0036456b6e
>> Author: yupeng <yupeng0921@gmail.com>
>> Date:   Tue Oct 24 23:55:29 2017 +0000
>>
>>     add additional explain in ss man page
>>
>>     Add detail explains of -m, -o, -e and -i options, which are not
>> documented anywhere
>>
>>     Signed-off-by: Peng Yu <yupeng0921@gmail.com>
>>
>> diff --git a/man/man8/ss.8 b/man/man8/ss.8
>> index 3bec97f..4597733 100644
>> --- a/man/man8/ss.8
>> +++ b/man/man8/ss.8
>> @@ -176,6 +176,147 @@ states except for
>>  - opposite to
>>  .B bucket
>>
>> +.SH Additional explain of -m, -o, -e and -i options
>> +Some fields may have different meanings if the netowrk protocl is
>> different. Below explain focus on tcp protocol.
>> +.TP
>> +.B -m option
>> +skmem:(r<rmem_alloc>,rb<rcv_buf>,t<wmem_alloc>,tb<snd_buf>,f<fwd_alloc>,w<wmem_queued>,o<opt_mem>,bl<back_log>)
>> +
>> +.B <rmem_alloc>
>> +the memory allocated for receiving package
>> +
>
> Need to change 'package' to 'packet' in multiple places.
>
> [...]
>
