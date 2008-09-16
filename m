From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
Date: Tue, 16 Sep 2008 15:10:33 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0809140722460.17271@wrl-59.cs.helsinki.fi>
References: <20080819213417.45133573@tux> <Pine.LNX.4.64.0808201358490.4551@wrl-59.cs.helsinki.fi>
 <20080822183224.2d52f16c@tux> <20080822.143709.65615512.davem@davemloft.net>
 <20080823111446.06a350a2@tux> <Pine.LNX.4.64.0808231736490.10712@wrl-59.cs.helsinki.fi>
 <20080824163843.33b4f890@tux> <Pine.LNX.4.64.0808250948420.27330@wrl-59.cs.helsinki.fi>
 <20080826141812.589848a0@tux> <Pine.LNX.4.64.0808262034001.1168@wrl-59.cs.helsinki.fi>
 <20080828184919.611dd578@tux> <Pine.LNX.4.64.0808291045430.7971@wrl-59.cs.helsinki.fi>
 <20080830035650.42be37d7@tux> <Pine.LNX.4.64.0808301000180.12388@wrl-59.cs.helsinki.fi>
 <20080907051718.58bf133d@tux> <Pine.LNX.4.64.0809071341310.8991@wrl-59.cs.helsinki.fi>
 <20080908172043.0d25a427@tux> <Pine.LNX.4.64.0809100942370.24708@wrl-59.cs.helsinki.fi>
 <20080911143006.2f516569@tux> <Pine.LNX.4.64.0809112140250.26799@wrl-59.cs.helsinki.fi>
 <20080913203117.2a55ea2c@tux>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1332387434-1221366290=:17271"
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "=?ISO-8859-1?Q?D=E2niel?= Fraga" <fragabr@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080913203117.2a55ea2c@tux>
Content-ID: <Pine.LNX.4.64.0809161503240.1034@wrl-59.cs.helsinki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1332387434-1221366290=:17271
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0809160942301.18199@wrl-59.cs.helsinki.fi>

I've copied stuff from the other mail to here... Sorry for the delay, I 
had already looked into it but left it as postponed and I've been busy in 
other things...

On Sat, 13 Sep 2008, Dâniel Fraga wrote:

> 	Ilpo, except for DROP [INPUT] lines, does the log below means something to you?
> 
> Sep 13 20:01:21 teleporto vmunix: DROP [INPUT]: IN=eth0 OUT= MAC=ff:ff:ff:ff:ff:ff:00:50:73:6c:4b:e5:08:00 SRC=189.31.180.2 DST=255.255.255.255 LEN=48 TOS=0x00 PREC=0x00 TTL=116 ID=20607 DF PROTO=TCP SPT=4038 DPT=4899 WINDOW=65535 RES=0x00 SYN URGP=0 
> Sep 13 20:01:21 teleporto vmunix: DROP [INPUT]: IN=eth0 OUT= MAC=ff:ff:ff:ff:ff:ff:00:50:73:6c:4b:e5:08:00 SRC=189.31.180.2 DST=255.255.255.255 LEN=48 TOS=0x00 PREC=0x00 TTL=116 ID=20616 DF PROTO=TCP SPT=4054 DPT=4899 WINDOW=65535 RES=0x00 SYN URGP=0 
> Sep 13 20:01:21 teleporto vmunix: C193.8. S=5.5.5.5 E=8TS00 RC00 T=1 D262DF PROTO=TCP SPT=4146 DPT=4899 WINDOW=65535 RES=0x00 SYN URGP=0 
> Sep 13 20:01:22 teleporto vmunix: DROP [INPUT]: IN=eth0 OUT= MAC=ff:ff:ff:ff:ff:ff:00:50:73:6c:4b:e5:08:00 SRC=189.31.180.2 DST=255.255.255.255 LEN=48 TOS=0x00 PREC=0x00 TTL=116 ID=20690 DF PROTO=TCP SPT=4179 DPT=4899 WINDOW=65535 RES=0x00 SYN URGP=0 
> Sep 13 20:01:22 teleporto vmunix: DROP [INPUT]: IN=eth0 OUT= MAC=ff:ff:ff:ff:ff:ff:00:50:73:6c:4b:e5:08:00 SRC=189.31.180.2 DST=255.255.255.255 LEN=48 TOS=0x00 PREC=0x00 TTL=116 ID=20698 DF PROTO=TCP SPT=4201 DPT=4899 WINDOW=65535 RES=0x00 SYN URGP=0 
> Sep 13 20:01:22 teleporto vmunix: DROP [INPUT]: IN=eth0 OUT= MAC=ff:ff:ff:ff:ff:ff:00:50:73:6c:4b:e5:08:00 SRC=189.31.180.2 DST=255.255.255.255 LEN=48 TOS=0x00 PREC=0x00 TTL=116 ID=20707 DF PROTO=TCP SPT=4231 DPT=4899 WINDOW=65535 RES=0x00 SYN URGP=0 
> Sep 13 20:01:22 teleporto vmunix: DROP [INPUT]: IN=eth0 OUT= MAC=ff:ff:ff:ff:ff:ff:00:50:73:6c:4b:e5:08:00 SRC=189.31.180.2 DST=255.255.255.255 LEN=48 TOS=0x00 PREC=0x00 TTL=116 ID=20725 DF PROTO=TCP SPT=4294 DPT=4899 WINDOW=65535 RES=0x00 SYN URGP=0 
> Sep 13 20:01:22 teleporto vmunix: OOTPST45 P=89WNO=53 E=x0SNUG= 
> 
> 	I mean these lines:
> 
> SRC=189.31.180.2 DST=255.255.255.255 LEN=48 TOS=0x00 PREC=0x00 TTL=116 ID=20616
> C193.8. S=5.5.5.5 E=8TS00 RC00 T=1 D262

...Funny, it's printing every second character of a correct line. How 
that can happen, other people are much more qualified to give a meaningful 
answer...

> Sep 13 20:01:22 teleporto vmunix: OOTPST45 P=89WNO=53 E=x0SNUG= 
> 
> This strange kernel messages are normal or is this clearly something
> buggy? This is logged whenever the connection is stalled.

I've no idea how they get generated.

>        Anyway, I'm 50% almost sure that it's something related to ntpd
> adjusting time. I do not mean that whenever ntpd syncs 
> the time, the connection is stalled but I need a few more weeks to 
> assure this.

How positive you actually are that it's exactly at that time? Ie., have 
you really check that the timing really matches as ntp syncs time every 
now and then, I wouldn't be surprised if it would happen "always" close 
enough to give a false alarm.

"50% almost sure" didn't sound that convincing (whatever it means in the 
first place).

>        Basically without ntpd, everything is fine, but when ntpd is
> running, the stall happens. Maybe the kernel gets confused when 
> ntpd changes the time? It shouldn't happen of course. I'll reply in a 
> few weeks. Thanks.

Only thing I know to ask is, do you have any idea if your ntpd is 
hard-stepping the time instead of adjusting the clock's rate a bit (the 
latter should keep the clock monotonious besides potential bugs)?

-- 
 i.
---696208474-1332387434-1221366290=:17271--
