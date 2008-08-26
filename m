From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround
Date: Tue, 26 Aug 2008 18:17:31 -0300
Message-ID: <20080826181731.4581fd2c@tux>
References: <20080819213417.45133573@tux>
	<Pine.LNX.4.64.0808201358490.4551@wrl-59.cs.helsinki.fi>
	<20080822183224.2d52f16c@tux>
	<20080822.143709.65615512.davem@davemloft.net>
	<20080823111446.06a350a2@tux>
	<Pine.LNX.4.64.0808231736490.10712@wrl-59.cs.helsinki.fi>
	<20080824163843.33b4f890@tux>
	<Pine.LNX.4.64.0808250948420.27330@wrl-59.cs.helsinki.fi>
	<20080826141812.589848a0@tux>
	<Pine.LNX.4.64.0808262034001.1168@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0808262034001.1168@wrl-59.cs.helsinki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 26 Aug 2008 23:40:58 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> If you want to, a tcpdump from normal, working case wouldn't hurt eit=
her=20
> to show the "normal pattern" on network level and that is trivial to=20
> produce in no time now that you know the commands etc. I guess... :-)

	Ok, there it is:

http://www.abusar.org/htb/dump-normal.log
=09
	Just the port 995... I checked email, then received a message,
checked again, just the normal behaviour.

> They might not be that interested until we have something more concre=
te=20
> than what we know currently... :-)

	Ok :) And you're right, because if I disable frto and htb *and*
the problem has gone, there's a huge chance to be something related to
kernel. Or a mix of kernel and user space problem which happens just
when frto and/or htb are used.

> Can you explain a bit more. Does it resolve during it or some time af=
ter=20
> it? And more importantly how do you know that it resolves? Ie., what =
is=20
> the normal behavior (be more specific than "it works" :-), how do kno=
w=20
> that it's working).

	Ok. For example:

1) the connection is normal, then suddenly it stalls. I cannot receive
mail, nor download nntp messages, nor access ftp etc.

2) I do on my client machine a "nmap -sS server" and...

3) ...imediatelly the connection is not stalled anymore.

	Now I remembered one thing and I'd like to make a question (I
hope it isn't a stupid question): dynticks (tickless) were implemented
for x86-64 in 2.6.24 kernel and I started to use dynticks in 2.6.24. Co=
uld=20
it be affecting the server behaviour? I use dynticks (enabled) on all
my machines, but does it make sense to use in a server environment?
Could the dynticks cause this? Until now, I don't think so, but... who
knows?

http://kernelnewbies.org/Linux_2_6_24#head-4edc562fa1b9fa8e5da5adaf1bea=
b057237c325d

> It seems that either we lack some traffic between the parties or simp=
ly=20
> need to find out what the userspace is doing, and in the latter case =
what=20
> happens in the network might not be relevant at all. Is there possibi=
lity=20
> that we miss an alternative route by using the host rule for tcpdump =
(at=20
> the server)? Nmap starts at 22:26:26.613098, the last packet in the c=
lient=20
> log is at 22:26:01.452842. Alternatively, the port 995 was not the ri=
ght=20
> one to track (though there's clearly this on network level visible pr=
oblem=20
> with it too)... :-(

	I tracked the 995 port, because I have problems reading email
pro pop3s (995). Should I do it different with tcpdump?=20

> You might jump into conclusions too quickly every now and then, more
> time might be needed to really ensure something is working. Obviously
> if any non-workingness is noticed, it's always a counter-proof even i=
f=20
> long working periods occur in between.

	Ok. It seems a complex issue. You're right. I need more
patience ;)

> In syscall terms this ListenOverflow means that int listen(int sockfd=
, int=20
> backlog); (see man -S 2 listen) is given some size as backlog for tho=
se=20
> connections that are not yet accept()'ed, and that is exhausted when =
the=20
> ListenOverflow gets incremented (ie., if I'm not completely wrong :-)=
).

	Hmm interesting.

> You might want to look on dovecot how to make it accept more concurre=
nt=20
> connections, perhaps the login_max_processes_count might the right on=
e
> (I quickly glanced http://wiki.dovecot.org/LoginProcess) though this =
is=20
> somewhat site configuration dependant according to that page.

	Yes, I have login_max_processes_count =3D 128 (the default) and I
have just a few users (just 10 users), so I think it's not the problem.
=20
> You could try setting up some script which does something along these=
=20
> lines and then redirect its during the event to some file (+ tcpdumpi=
ng=20
> the thing obviously):
>=20
> while [ : ]; do
> 	date "+%s.%N"
> 	cat /proc/net/{netstat,snmp}
> 	sleep 1
> done

	Ok. You're helping a lot. Thanks Ilpo ;)


--=20
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
