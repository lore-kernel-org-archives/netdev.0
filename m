From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 6966] New: ftp conntrack doesn't work
Date: Sun, 6 Aug 2006 11:53:41 -0700
Message-ID: <20060806115341.eaf6fa68.akpm@osdl.org>
References: <200608061412.k76ECuj5027156@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, pentek_i@inf.elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18842 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750975AbWHFSyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Aug 2006 14:54:03 -0400
To: netdev@vger.kernel.org
In-Reply-To: <200608061412.k76ECuj5027156@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 6 Aug 2006 07:12:56 -0700
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=6966
> 
>            Summary: ftp conntrack doesn't work
>     Kernel Version: 2.6.17.6
>             Status: NEW
>           Severity: normal
>              Owner: laforge@gnumonks.org
>          Submitter: pentek_i@inf.elte.hu
> 
> 
> Most recent kernel where this bug did not occur:
> Distribution: UHU-Linux 2.0 test 3
> Hardware Environment:
> Software Environment: lftp, ncftp (in active mode)
> Problem Description: ftp conntrack doesn't work
> 
> root:~# lsmod|grep conn
> ip_conntrack_tftp       7288  0 
> ip_conntrack_ftp        9712  0 
> ip_conntrack           40128  6 
> ip_conntrack_tftp,ip_conntrack_ftp,ipt_MASQUERADE,xt_state,iptable_nat,ip_nat
> root:~#
> 
> Chain INPUT (policy DROP)
> target     prot opt source               destination         
> ACCEPT     all  --  anywhere             anywhere //this one is iptables -A
> INPUT -i lo -j ACCEPT
> LOG        all  --  anywhere             anywhere            state NEW LOG 
> level warning tcp-sequence tcp-options ip-options prefix `NEW IN ' 
> LOG        all  --  anywhere             anywhere            state RELATED LOG 
> level warning tcp-sequence tcp-options ip-options prefix `RELATED OK ' 
> ACCEPT     all  --  anywhere             anywhere            state 
> RELATED,ESTABLISHED 
> ACCEPT     icmp --  anywhere             anywhere            
> ACCEPT     tcp  --  anywhere             anywhere            tcp dpt:50044 
> state NEW 
> 
> Chain FORWARD (policy DROP)
> target     prot opt source               destination         
> ACCEPT     icmp --  anywhere             anywhere            
> ACCEPT     all  --  anywhere             anywhere            
> ACCEPT     all  --  anywhere             anywhere            state 
> RELATED,ESTABLISHED 
> 
> Chain OUTPUT (policy ACCEPT)
> target     prot opt source               destination         
> LOG        all  --  anywhere             anywhere            state NEW LOG 
> level warning tcp-sequence tcp-options ip-options prefix `NEW OUT '
> 
> Log:
> Aug  5 23:17:42 localhost kernel: [17239490.784000] NEW OUT IN= OUT=ppp0
> SRC=84.0.221.87 DST=80.77.113.72 LEN=60 TOS=0x10 PREC=0x00 TTL=64 ID=12307 DF
> PROTO=TCP SPT=50192 DPT=21 SEQ=2383560747 ACK=0 WINDOW=5808 RES=0x00 SYN URGP=0
> OPT (020405AC0402080A00E370380000000001030304)
> Aug  5 23:17:42 localhost kernel: [17239490.828000] NEW IN IN=ppp0 OUT= MAC=
> SRC=80.77.113.59 DST=84.0.221.87 LEN=60 TOS=0x00 PREC=0x00 TTL=60 ID=37994 DF
> PROTO=TCP SPT=42891 DPT=113 SEQ=3129894276 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0
> OPT (020405840402080A059FF1EE0000000001030302)
> Aug  5 23:17:45 localhost kernel: [17239493.828000] NEW IN IN=ppp0 OUT= MAC=
> SRC=80.77.113.59 DST=84.0.221.87 LEN=60 TOS=0x00 PREC=0x00 TTL=60 ID=37996 DF
> PROTO=TCP SPT=42891 DPT=113 SEQ=3129894276 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0
> OPT (020405840402080A059FF4DC0000000001030302)
> Aug  5 23:17:51 localhost kernel: [17239499.824000] NEW IN IN=ppp0 OUT= MAC=
> SRC=80.77.113.59 DST=84.0.221.87 LEN=60 TOS=0x00 PREC=0x00 TTL=60 ID=37998 DF
> PROTO=TCP SPT=42891 DPT=113 SEQ=3129894276 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0
> OPT (020405840402080A059FFAB80000000001030302)
> Aug  5 23:17:53 localhost kernel: [17239502.576000] NEW IN IN=ppp0 OUT= MAC=
> SRC=80.77.113.59 DST=84.0.221.87 LEN=60 TOS=0x00 PREC=0x00 TTL=60 ID=34195 DF
> PROTO=TCP SPT=20 DPT=52039 SEQ=3131996404 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0
> OPT (020405840402080A059FFD670000000001030302)
> Aug  5 23:17:56 localhost kernel: [17239505.576000] NEW IN IN=ppp0 OUT= MAC=
> SRC=80.77.113.59 DST=84.0.221.87 LEN=60 TOS=0x00 PREC=0x00 TTL=60 ID=34197 DF
> PROTO=TCP SPT=20 DPT=52039 SEQ=3131996404 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0
> OPT (020405840402080A05A000550000000001030302)
> Aug  5 23:17:58 localhost kernel: [17239507.492000] NEW IN IN=ppp0 OUT= MAC=
> SRC=84.0.239.162 DST=84.0.221.87 LEN=48 TOS=0x00 PREC=0x00 TTL=125 ID=51878 DF
> PROTO=TCP SPT=3044 DPT=445 SEQ=2602678088 ACK=0 WINDOW=64800 RES=0x00 SYN URGP=0
> OPT (0204058401010402)
> Aug  5 23:18:02 localhost kernel: [17239510.720000] NEW IN IN=ppp0 OUT= MAC=
> SRC=84.0.239.162 DST=84.0.221.87 LEN=48 TOS=0x00 PREC=0x00 TTL=125 ID=52423 DF
> PROTO=TCP SPT=3044 DPT=445 SEQ=2602678088 ACK=0 WINDOW=64800 RES=0x00 SYN URGP=0
> OPT (0204058401010402)
> Aug  5 23:18:02 localhost kernel: [17239511.572000] NEW IN IN=ppp0 OUT= MAC=
> SRC=80.77.113.59 DST=84.0.221.87 LEN=60 TOS=0x00 PREC=0x00 TTL=60 ID=34199 DF
> PROTO=TCP SPT=20 DPT=52039 SEQ=3131996404 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0
> OPT (020405840402080A05A006310000000001030302)
> Aug  5 23:18:10 localhost kernel: [17239518.816000] NEW IN IN=ppp0 OUT= MAC=
> SRC=180.70.71.68 DST=84.0.221.87 LEN=508 TOS=0x00 PREC=0x00 TTL=56 ID=29063
> PROTO=UDP SPT=30975 DPT=1026 LEN=488
> Aug  5 23:18:10 localhost kernel: [17239519.168000] NEW IN IN=ppp0 OUT= MAC=
> SRC=84.0.236.215 DST=84.0.221.87 LEN=48 TOS=0x00 PREC=0x00 TTL=125 ID=2873 DF
> PROTO=TCP SPT=3583 DPT=445 SEQ=1195142382 ACK=0 WINDOW=64800 RES=0x00 SYN URGP=0
> OPT (0204058401010402)
> Aug  5 23:18:13 localhost kernel: [17239522.000000] NEW IN IN=ppp0 OUT= MAC=
> SRC=84.0.236.215 DST=84.0.221.87 LEN=48 TOS=0x00 PREC=0x00 TTL=125 ID=2944 DF
> PROTO=TCP SPT=3583 DPT=445 SEQ=1195142382 ACK=0 WINDOW=64800 RES=0x00 SYN URGP=0
> OPT (0204058401010402)
> Aug  5 23:18:14 localhost kernel: [17239523.572000] NEW IN IN=ppp0 OUT= MAC=
> SRC=80.77.113.59 DST=84.0.221.87 LEN=60 TOS=0x00 PREC=0x00 TTL=60 ID=34201 DF
> PROTO=TCP SPT=20 DPT=52039 SEQ=3131996404 ACK=0 WINDOW=5840 RES=0x00 SYN URGP=0
> OPT (020405840402080A05A011E90000000001030302)
> Aug  5 23:18:26 localhost kernel: [17239535.652000] NEW IN IN=ppp0 OUT= MAC=
> SRC=221.208.208.104 DST=84.0.221.87 LEN=485 TOS=0x00 PREC=0x60 TTL=47 ID=0 DF
> PROTO=UDP SPT=46275 DPT=1027 LEN=465
> Aug  5 23:18:30 localhost kernel: [17239539.004000] NEW IN IN=ppp0 OUT= MAC=
> SRC=221.126.232.74 DST=84.0.221.87 LEN=90 TOS=0x00 PREC=0x00 TTL=121 ID=9429
> PROTO=UDP SPT=15868 DPT=13567 LEN=70
> 
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
