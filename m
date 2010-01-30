From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: debug: nt_conntrack and KVM crash
Date: Sat, 30 Jan 2010 09:33:35 +0100
Message-ID: <1264840415.2919.19.camel@edumazet-laptop>
References: <1264813832.2793.446.camel@tonnant>
	 <1264816634.2793.505.camel@tonnant>  <1264816777.2793.510.camel@tonnant>
	 <1264834704.2919.3.camel@edumazet-laptop> <1264836971.7499.4.camel@tonnant>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Jon Masters <jonathan@jonmasters.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752651Ab0A3Idm@vger.kernel.org>
In-Reply-To: <1264836971.7499.4.camel@tonnant>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 30 janvier 2010 =C3=A0 02:36 -0500, Jon Masters a =C3=A9crit =
:

> I'll play later. Right now, I'm looking over every iptables/ip call
> libvirt makes - it explicitly plays with the netns for the loopback,
> which looks interesting. Supposing it does cause the hashtables to ge=
t
> unintentionally zereod or the sizing to get wiped out, we should also
> nonetheless catch the case that the hash function generates a whacko
> number or that the hash size is set to zero when we want to use it.
>=20

I asked you if you had multiple namespaces, because I was not sure
conntracking hash was global (shared by all namespaces), or local.

If it is local, then we have a bug, because nf_conntrack_cachep=20
is still shared.

Because of SLAB_DESTROY_BY_RCU constraint, we must use a distinct
cachep, or an object can be freed from a namespace and immediatly reuse=
d
into another namespace, without lookups being able to notice.
