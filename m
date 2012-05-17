From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tcp timestamp issues with google servers
Date: Thu, 17 May 2012 20:12:43 +0200
Message-ID: <1337278363.3403.39.camel@edumazet-glaptop>
References: <87r4ujno34.fsf@tucsk.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87r4ujno34.fsf@tucsk.pomaz.szeredi.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-05-17 at 11:39 +0200, Miklos Szeredi wrote:
> Sometimes connection to google.com, gmail.com and other google servers
> doesn't work or takes ages to connect.  When this hits it hits all
> google servers at the same time and it's persistent.  It never happens
> to anything other than google.  Rebooting helps.  Rarely it goes away
> spontaneously.
> 
> Apparently google is sometimes replying with an invalid TSecr timestamp
> value (smaller than the one sent in the last packet) and this confuses
> the Linux TCP stack which either discards the packet or sends a Reset.
> 
> Network dump attached.
> 
> I found only a couple of references to this issue:
> 
> http://gotchas.livejournal.com/3028.html
> 
> http://groups.google.com/group/comp.os.linux.networking/browse_thread/thread/29f56feded11b42a
> 
> Turning tcp timestamps fixes the issue:
> 
>   sysctl -w net.ipv4.tcp_timestamps=0
> 
> Not sure why this happens only to me and a very few others.
> 
> It appears to be an issue with google TCP stack (is it a modified
> stack?) but I thought about issues in my network switch (restarting it
> doesn't help) or something in the ISP, but those look unlikely.
> 
> Any ideas?
> 
> Thanks,
> Miklos
> 
> 
> 
>   1   0.000000 192.168.28.100 -> 74.125.232.226 TCP 51303 > http [SYN] Seq=0 Win=14600 Len=0 MSS=1460 SACK_PERM=1 TSV=35355050 TSER=0 WS=5
>   2   0.002730 74.125.232.226 -> 192.168.28.100 TCP http > 51303 [SYN, ACK] Seq=0 Ack=1 Win=14180 Len=0 MSS=1430 SACK_PERM=1 TSV=1184565067 TSER=35325344 WS=6


Do you really have 2730 usec RTT between you and this (Google ?)
server ?

Are you sure this is not a broken middle box ?
