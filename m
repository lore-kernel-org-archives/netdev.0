From: Borislav Petkov <bp@alien8.de>
Subject: Re: Instead of IP addresses the kernel started to show zero's
Date: Mon, 1 Oct 2012 01:03:45 +0200
Message-ID: <20120930230345.GA9142@liondog.tnic>
References: <20120925102607.GC23296@beaver>
 <20120930232559.03a0ce4c@wc1>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Alexey Vlasov <renton@renton.name>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Giuliano Pochini <pochini@shiny.it>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120930232559.03a0ce4c@wc1>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

+ netdev

On Sun, Sep 30, 2012 at 11:25:59PM +0200, Giuliano Pochini wrote:
> On Tue, 25 Sep 2012 14:26:07 +0400
> Alexey Vlasov <renton@renton.name> wrote:
> 
> > Hi.
> > 
> > Here it writes LOG target from syslog:
> > 
> > Sep 25 03:23:49 l24 kernel: ip:SYN-OUTPUT-HTTP IN= OUT=eth0
> > SRC=0000000000000000 DST=0000000000000000 LEN=60 TOS=0x00 PREC=0x00
> > TTL=64 ID=22467 DF PROTO=TCP SPT=52829 DPT=80 WINDOW=14600 RES=0x00 SYN
> > URGP=0 UID=564373 GID=155
> > 
> > This is recent, here go zero's again:
> > # cat /proc/net/xt_recent/ssh-brute
> > ...
> > src=0000000000000000 ttl: 122 last_seen: 4371027622 oldest_pkt: 1
> > 4371027622
> >
> > Can it be fixed without restarting the box?
> > Thanks!
> >
> > Kernel 3.4.6.
> 
> It look similar to a problem that occurred on some 3.x heavy loaded
> machines. After a while they begin to send packets with dst=0.0.0.0. We had
> to revert to 2.6 on our production machines.
> 
> tcpdump output looks like this:
> 
> 17:06:29.272225 IP 0.0.0.0.http > 0.0.0.0.1687: . ack 232 win 15400
> 17:06:29.272671 IP 0.0.0.0.http > 0.0.0.0.1687: P 0:511(511) ack 232 win 15400
> 17:06:29.272689 IP 0.0.0.0.http > 0.0.0.0.1687: F 511:511(0) ack 232 win 15400
> 17:06:29.273249 IP 0.0.0.0.http > 0.0.0.0.65307: . ack 62552748 win 1006 <nop,nop,timestamp 1760963 478909562>
> 17:06:29.273662 IP 0.0.0.0.http > 0.0.0.0.65307: P 0:511(511) ack 1 win 1006 <nop,nop,timestamp 1760963 478909562>
> 17:06:29.273678 IP 0.0.0.0.http > 0.0.0.0.65307: F 511:511(0) ack 1 win 1006 <nop,nop,timestamp 1760963 478909562>
> 17:06:29.278683 IP 0.0.0.0.http > 0.0.0.0.12021: . ack 1 win 12240
> 17:06:29.288707 IP 0.0.0.0.http > 0.0.0.0.28308: . ack 1049058319 win 12420
> 17:06:29.289406 IP 0.0.0.0.http > 0.0.0.0.28308: . ack 57 win 12420
> 17:06:29.289834 IP 0.0.0.0.http > 0.0.0.0.28308: P 0:487(487) ack 57 win 12420
> 17:06:29.289851 IP 0.0.0.0.http > 0.0.0.0.28308: F 487:487(0) ack 57 win 12420
> 17:06:29.291767 IP 0.0.0.0.http > 0.0.0.0.11407: P 0:472(472) ack 171 win 1275 <nop,nop,timestamp 1760982 2400635630>
> 17:06:29.292657 IP 0.0.0.0.http > 0.0.0.0.50511: . ack 1 win 14400
> 17:06:29.293502 IP 0.0.0.0.http > 0.0.0.0.12381: . ack 558 win 14960
> 17:06:29.295080 IP 0.0.0.0.http > 0.0.0.0.10980: . ack 2 win 16692
> 
> When the network traffic slows down the machine recovers to normal operation.
> 
> I found another report about this issue:
> 
> https://bbs.archlinux.org/viewtopic.php?id=129304

Any chance you guys can try the latest Linus kernel - it is 3.6-rc7 +
100ish patches and it should be close to final release, so pretty stable
already - to check whether the issue still persists?

Thanks.

-- 
Regards/Gruss,
    Boris.
