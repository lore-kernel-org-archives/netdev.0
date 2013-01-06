From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Major network performance regression in 3.7
Date: Sun, 06 Jan 2013 06:59:02 -0800
Message-ID: <1357484342.6919.61.camel@edumazet-glaptop>
References: <20130105232913.GQ16031@1wt.eu>
	 <1357430523.1678.4901.camel@edumazet-glaptop>
	 <20130106005053.GS16031@1wt.eu>
	 <1357435276.1678.5067.camel@edumazet-glaptop>
	 <20130106013027.GV16031@1wt.eu>
	 <1357436430.1678.5111.camel@edumazet-glaptop>
	 <1357437086.1678.5135.camel@edumazet-glaptop>
	 <1357438591.1678.5205.camel@edumazet-glaptop>
	 <20130106025256.GY16031@1wt.eu>
	 <1357457724.1678.5941.camel@edumazet-glaptop>
	 <20130106092435.GZ16031@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130106092435.GZ16031@1wt.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-01-06 at 10:24 +0100, Willy Tarreau wrote:

> It does not change anything to the tests above unfortunately. It did not
> even stabilize the unstable runs.
> 
> I'll check if I can spot the original commit which caused the regression
> for MTUs that are not n*4096+52.

Since you don't post your program, I wont be able to help, just by
guessing what it does...

TCP has very low defaults concerning initial window, and it appears you
set RCVBUF to even smaller values.

Here we can see "win 8030", this is not a sane value...

18:32:08.071602 IP 127.0.0.1.26792 > 127.0.0.1.8000: S 2036886615:2036886615(0) win 8030 <mss 65495,nop,nop,sackOK,nop,wscale 9>
18:32:08.071605 IP 127.0.0.1.8000 > 127.0.0.1.26792: S 126397113:126397113(0) ack 2036886616 win 8030 <mss 65495,nop,nop,sackOK,nop,wscale 9>

So you apparently changed /proc/sys/net/ipv4/tcp_rmem or SO_RCVBUF ?
