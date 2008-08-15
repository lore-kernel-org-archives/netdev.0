From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
Date: Sat, 16 Aug 2008 01:06:55 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808160039230.6911@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0808081256560.4551@wrl-59.cs.helsinki.fi>
 <20080811.144421.234396007.davem@davemloft.net> <200808120946.19459.thomas.jarosch@intra2net.com>
 <20080812.011822.155249871.davem@davemloft.net> <20080812144309.7d62fd86@tux>
 <Pine.LNX.4.64.0808122044450.16105@wrl-59.cs.helsinki.fi> <20080813145310.0c1e534c@tux>
 <Pine.LNX.4.64.0808132108480.18807@wrl-59.cs.helsinki.fi> <20080815013407.4a594288@tux>
 <Pine.LNX.4.64.0808150939270.23522@wrl-59.cs.helsinki.fi> <20080815183511.1c81be23@tux>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1750383282-1218836673=:6911"
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>, sr@securenet.de,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "=?ISO-8859-1?Q?D=E2niel?= Fraga" <fragabr@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080815183511.1c81be23@tux>
Content-ID: <Pine.LNX.4.64.0808160101480.6911@wrl-59.cs.helsinki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1750383282-1218836673=:6911
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0808160045201.6911@wrl-59.cs.helsinki.fi>

On Fri, 15 Aug 2008, Dâniel Fraga wrote:

> On Fri, 15 Aug 2008 10:06:39 +0300 (EEST)
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > I would be better to have tcpdump running at least a bit back (2-3 windows 
> > back is long enough for me), but obviously that might not be possible 
> > option because it occurs so rarely. ...It should be possible to have 
> > tcpdump restarted once in a while to avoid a one huge log if you'd just 
> > keep running tcpdump from beginning.
> 
> 	Ok.
> 
> > What do you mean by "come back alive"...? ...In eth0 log I found this 
> 
> 	I mean, it isn't stalled anymore. When it stalls, fetchnews
> stops and stay stalled forever. When it come back alive, it resumes
> (but it will only do that if I do something to restore the connection).

Ok. I hope it will still reproduce with tcpdump running... Btw, doing cat 
/proc/net/tcp during the stall wouldn't be a bad idea (in addition to 
tcpdumping it). Also please let the tcpdumps run long enough if the stall 
persists, something like 15mins doesn't hurt because there are large 
timer values possibly involved.

You might have mentioned it but I would like you to confirm which kernel 
version the server is running (at least 2.6.25.7 or 2.6.26 is new enough 
to have all bug fixes)?

> > connection 189.38.18.122.995 > 192.168.0.2.35477, the ip matches with 
> > abusar's. But I'm not sure if the connection in the tunnel is the 
> > interesting one, since it's going to/from port 119 but the ip addresses 
> > (10.195.195.2 and 10.195.195.1) don't tell anything to me, I guess you 
> > know their meaning (ie., if 10.195.195.2 is the one with which the 
> > connection stalls)? ...You're probably right that this wasn't very useful 
> > log, the longest "stall" I find is only 1.111328 seconds long (and it 
> > might be due to some processing that is made by 10.195.195.2).
> 
> 	Ok:
> 
> 10.195.195.1 is my local VPN IP (tun1)
> 
> 10.195.195.2 is the remote VPN IP (on the server)

I sort of assumed so, thanks for the confirmation.

> 192.168.0.2 is my local IP (eth0)
> 
> 189.38.18.122 is the server's IP
> 
> 	Should I use tcpdump on the server too or is it sufficient to
> use on my client machine?

It definately wouldn't hurt (though I usually can figure out what happens 
in the other end) and I guess it's quite easy for you to arrange.

In case there's some other use than your testing traffic with the server, 
it's probably polite to filter there aggressively enough to not get that 
much unrelated traffic (tcpdump ... host <ip> and host <clientip> and port 
<portnum>, or so, I guess the ip address pair should be the vpn endpoints 
since the nntp traffic seems to go through it and the portnum is 119, if 
unsure you can verify with sudo netstat -p which tcp connections are 
associated to fetchnews if that's not immediately obvious).


-- 
 i.
---696208474-1750383282-1218836673=:6911--
