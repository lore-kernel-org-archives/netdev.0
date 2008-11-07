From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: time for TCP ECN defaulting to on?
Date: Fri, 7 Nov 2008 12:38:59 +0100 (CET)
Message-ID: <alpine.DEB.1.10.0811071230310.10993@uplift.swm.pp.se>
References: <6278d2220811040632u7a36d68ekad5de517fd0671bb@mail.gmail.com> <alpine.DEB.1.10.0811052316210.10993@uplift.swm.pp.se> <20081105.151015.206163697.davem@davemloft.net> <alpine.DEB.1.10.0811070529550.10993@uplift.swm.pp.se>
 <Pine.LNX.4.64.0811070931190.23284@wrl-59.cs.helsinki.fi> <alpine.DEB.1.10.0811070854361.10993@uplift.swm.pp.se> <Pine.LNX.4.64.0811071039480.23629@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-137064504-1445617518-1226057771=:10993"
Cc: David Miller <davem@davemloft.net>, daniel.blueman@gmail.com,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, linux-net@vger.kernel.org
To: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0811071039480.23629@wrl-59.cs.helsinki.fi>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---137064504-1445617518-1226057771=:10993
Content-Type: TEXT/PLAIN; CHARSET=ISO-8859-15; FORMAT=flowed
Content-Transfer-Encoding: 8BIT

On Fri, 7 Nov 2008, Ilpo Järvinen wrote:

> I think you partially miss the point here. In many cases not every 
> single router has to _support_ ECN to get its benefits, not-supporting 
> is not the problem in itself (though it would be nice to get that 
> "fixed" as well) but breaking ecn-enabled connections. I suppose you 
> didn't check that aspect? I'd guess those mentioned devices will 
> interoperate just fine since one can mostly connect ok with ecn too 
> besides rare exceptions rather than things being vice-versa.

I don't understand. My point is that most of the ISP core equipment out 
there doesn't act on ECN rendering it mostly useless. The N in ECN renders 
useless because there is no device doing the *notification*. They'll just 
pass the traffic without acting on it differently regardless if ECN is on 
or off.

> The most crucial components are anyway the points of congestion, I don't know 
> enough isp topologies but I suppose those core routers are not the ones where 
> towards subscribers device traffic congests?

There can be congestion anywhere in the network, best would be if all 
routers supported it. My problem with ECN is that the most advanced 
routers do not support it, it's useless with L2/L3 switches (as they have 
very small buffers, there is "nothing" to do WRED on), so that leaves 
potential implementation by either DSLAM/BRAS vendors (where Cisco BRAS 
does support it but it needs to be enabled by the ISP) or the SOHO devices 
which run Linux and might implement it, but I'd rather see them do active 
queue management at all (fair-queue for instance) before asking them to do 
ECN. Of course, if users start to ask for ECN and we get fair-queue at the 
same time, all the better. One very common congestion point is definitely 
the upstream connection of someones cable or DSL modem.

> I doubt it any worse than with eg. timestamps.

According to <http://www.imperialviolet.org/binary/ecntest.pdf> it's 0.5% 
of hosts that drop packets when ECN is enabled. It's a substantial part of 
the Internet. Yes, not doing blackhole detection might get these hosts 
fixed faster, but at the expense of more end user hurt.

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se
---137064504-1445617518-1226057771=:10993--
