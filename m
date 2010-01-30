From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: debug: nt_conntrack and KVM crash
Date: Sat, 30 Jan 2010 05:03:14 -0500
Message-ID: <1264845794.7499.10.camel@tonnant>
References: <1264813832.2793.446.camel@tonnant>
	 <1264816634.2793.505.camel@tonnant>  <1264816777.2793.510.camel@tonnant>
	 <1264834704.2919.3.camel@edumazet-laptop> <1264836971.7499.4.camel@tonnant>
	 <1264840415.2919.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1264840415.2919.19.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2010-01-30 at 09:33 +0100, Eric Dumazet wrote:
> Le samedi 30 janvier 2010 =C3=A0 02:36 -0500, Jon Masters a =C3=A9cri=
t :
>=20
> > I'll play later. Right now, I'm looking over every iptables/ip call
> > libvirt makes - it explicitly plays with the netns for the loopback=
,
> > which looks interesting. Supposing it does cause the hashtables to =
get
> > unintentionally zereod or the sizing to get wiped out, we should al=
so
> > nonetheless catch the case that the hash function generates a whack=
o
> > number or that the hash size is set to zero when we want to use it.

> I asked you if you had multiple namespaces, because I was not sure
> conntracking hash was global (shared by all namespaces), or local.

Well, I didn't think I had multiple namespaces, and in fact I don't see
more than one in gdb when I poke at the net struct. What I see libvirt
doing (very oddly indeed - looking at the source now) is calling ip and
asking for the lo device to be moved into the netns for pid "-1", which
isn't valid AFAIK (should be a valid pid, unless "-1" is supposed to be
"this process" or something, haven't played with multiple namespaces).

I'll do some more digging (network stuff isn't my area) now and come
back. It only reproduces if multiple VMs start at once (hence a race,
perhaps as you describe) whereas if I disable autostart and let them
come up one at a time, the box doesn't roll over.

Jon.


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
