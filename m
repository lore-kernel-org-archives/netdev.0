From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
Date: Mon, 22 Sep 2008 14:22:12 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0809221112140.1950@wrl-59.cs.helsinki.fi>
References: <20080819213417.45133573@tux> <20080824163843.33b4f890@tux>
 <Pine.LNX.4.64.0808250948420.27330@wrl-59.cs.helsinki.fi> <20080826141812.589848a0@tux>
 <Pine.LNX.4.64.0808262034001.1168@wrl-59.cs.helsinki.fi> <20080828184919.611dd578@tux>
 <Pine.LNX.4.64.0808291045430.7971@wrl-59.cs.helsinki.fi> <20080830035650.42be37d7@tux>
 <Pine.LNX.4.64.0808301000180.12388@wrl-59.cs.helsinki.fi> <20080907051718.58bf133d@tux>
 <Pine.LNX.4.64.0809071341310.8991@wrl-59.cs.helsinki.fi> <20080908172043.0d25a427@tux>
 <Pine.LNX.4.64.0809100942370.24708@wrl-59.cs.helsinki.fi> <20080911143006.2f516569@tux>
 <Pine.LNX.4.64.0809112140250.26799@wrl-59.cs.helsinki.fi> <20080913203117.2a55ea2c@tux>
 <Pine.LNX.4.64.0809140722460.17271@wrl-59.cs.helsinki.fi> <20080916112411.062fa615@tux>
 <Pine.LNX.4.64.0809161726250.1034@wrl-59.cs.helsinki.fi> <20080918173554.1f874238@tux>
 <Pine.LNX.4.64.0809182349410.4742@wrl-59.cs.helsinki.fi> <20080922012338.694d30b0@tux>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-632985311-1222071466=:1950"
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "=?ISO-8859-1?Q?D=E2niel?= Fraga" <fragabr@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080922012338.694d30b0@tux>
Content-ID: <Pine.LNX.4.64.0809221408150.1034@wrl-59.cs.helsinki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-632985311-1222071466=:1950
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0809221352081.1034@wrl-59.cs.helsinki.fi>

On Mon, 22 Sep 2008, Dâniel Fraga wrote:

> On Fri, 19 Sep 2008 00:04:23 +0300 (EEST)
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > Anyway, if/when you succeed collecting some strace of the server 
> > processes, please let me know (though putting a full one available might 
> > not be wise thing like I said earlier). After I thought it a bit, it might 
> > be enough the start the strace with -p for all server processes of a 
> > service during a stall and then resolve it after some amount of waiting 
> > with nmap (and hope that strace doesn't resolve it by interfering 
> > something relevant :-), you will see that from the fact that it resolves 
> > without nmap then). That would probably reveal if the processes where 
> > waiting in accept() or not, and if not, where they were.
> 
> 	Hi again Ilpo, I waited the whole day for a stall, and
> fortunatelly it happened while I was stracing dovecot and child
> processes. The stall happened at 01:11 (at the end). I hope that it
> has something useful.

It definately shows a stall, there are _no_ events between 0:53 and 1:11 
while there isn't any other period like that, every other minute since the 
start has some activity going on :-). So this might not be related to 
networking at all like we've kind of already figured out (definately 
accept() has very little to do here). There weren't close()'es there 
either so it looks very stuck on something that's outside of the syscalls 
we listed in -e, I suppose...

It seems that next sensible step is to just obtain a full strace to see 
what actually took place during those long minutes if anything (it's 
better that you keep that log private and just use grep over it on 
request). ...A full strace might grow huge though. Also, for strace use 
-tt instead of -t to get more accurate timestamps and add -T.

When you get the stall next time, please also check that the processes are 
actually sleeping instead of looping like crazy in some buggy userspace 
code :-) (obviously before resolving it with nmap).

When using nmap to resolve, take note on exact timestamp (including 
seconds). E.g., 
$ date > nmap.ts; nmap ...


-- 
 i.
---696208474-632985311-1222071466=:1950--
