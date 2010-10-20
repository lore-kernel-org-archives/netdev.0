From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Linux 2.6.35/TIPC 2.0 ABI breaking changes
Date: Wed, 20 Oct 2010 13:57:32 -0400
Message-ID: <20101020175732.GB14407@hmsreliant.think-freely.org>
References: <4CBCD429.8090306@windriver.com>
 <20101018234547.GA5703@hmsreliant.think-freely.org>
 <20101019021657.GZ8781@llucax.com.ar>
 <20101019.011649.71113115.davem@davemloft.net>
 <20101019110452.GA14410@hmsreliant.think-freely.org>
 <20101019131936.GB8781@llucax.com.ar>
 <20101019201841.GC14410@hmsreliant.think-freely.org>
 <20101020172018.GN8781@llucax.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, paul.gortmaker@windriver.com,
	jon.maloy@ericsson.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: Leandro Lucarella <luca@llucax.com.ar>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101020172018.GN8781@llucax.com.ar>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 20, 2010 at 02:20:18PM -0300, Leandro Lucarella wrote:
> Neil Horman, el 19 de octubre a las 16:18 me escribiste:
> > 	Heres what I have so far.  Dave as a heads up please don't apply t=
his
> > yet.  I'd like to go over it a bit more and be sure of the implicat=
ions here
> > before I post it for inclusion officially.  I wanted Leandro to hav=
e a copy
> > though so he could confirm functionality for us.  Leandro, This pat=
ch lets me
> > pass the tipc test code for TIPC 1.6 that you posted earlier this m=
orning.  If
> > you could confirm that it works for you that would be grand.  While=
 your doing
> > that, I want to read over the spec for TIPC and make sure that I'm =
not breaking
> > anything new with this patch.
>=20
> I tried the patch (swapping the values of TIPC_SUB_SERVICE and
> TIPC_SUB_PORTS) based on 2.6.35.4 and it didn't worked. dmesg sais:
> NOT Swapping endianess in subscr_subscribe
> NOT Swapping endianess in subscr_subscribe
> TIPC: Subscription rejected, illegal request
thats odd, it worked fine for me.  I wonder If I had an older tipc.h he=
ader that
set the flags properly in user space.

>=20
> I tried with a binary compiled with an older tipc.h header, I didn't
> tried to recompile it using the new tipc.h (on purpose as the thing t=
hat
> should be fixed is backwards compatibility).
>=20
> I've read the TIPC 2.0 specification[1] a little more, and as I see, =
the
> subscription messages are not supposed to go through the wire[2].
>=20
> 	8.  Topology Service
>=20
> 	TIPC provides a message-based mechanism for an application to
> 	learn about the port names that are visible to its node. This is
> 	achieved by communicating with a Topology Service that has
> 	knowledge of the contents of the node's name table.
>=20
> So, if the idea is to comply with TIPC 2.0, the topology service shou=
ld
> accept the new TIPC_SUB_SERVICE and TIPC_SUB_PORTS values (0 and
> 1 in NBO respectively), and all the fields in the subscr struct shoul=
d
> be filled in NBO too.
>=20
> However, if the idea is to keep backwards compatibility too, HBO shou=
ld
> be accepted as well as the old TIPC_SUB_SERVICE and TIPC_SUB_PORTS
> values (2 and 1 in HBO respectively).
>=20
> The real problem is, we can't figure out the endianess of the subscr
> struct because 0x0 is a valid filter in TIPC 2.0.
>=20
> The only solution I see is to change the TIPC 2.0 specification (whic=
h
> is a "work-in-progress") to make the topology service use the port na=
me
> {2,2}, leaving {1,1} for backwards compatibility. Then add the consta=
nts
> TIPC_SUB_SERVICE2 (0) and TIPC_TOP_SRV2 (2), or similar, to use the T=
IPC
> 2.0 interface and leave TIPC_SUB_SERVICE and TIPC_TOP_SRV for the TIP=
C
> 1.x interface.
>=20
> Another option is to change the TIPC 2.0 specification to use the old
> format (use HBO in subscriptions and keep TIPC_SUB_SERVICE as a separ=
ate
> flag with value 2) and forget about all this. After all, I can't see
> what advantages gives having to change the BO for internal messages
> between the applications and the stack.
>=20
> [1] http://tipc.sourceforge.net/doc/draft-spec-tipc-06.html
> [2] http://tipc.sourceforge.net/doc/draft-spec-tipc-06.html#anchor92
>=20
Ugh, the tipc 'spec' is just a mess (note section 2.4.2, 8.2.1, etc  al=
so indicates all
mesages should be in network byte order)

What we should probably do is, for the time being, just revert my endia=
n swap
commit, plus pauls bit field change to get us back to a point where we'=
re no
longer breaking user space.  Then we can take our time to find a way to=
 conform
to the spec in a backwards compatible manner.  I'll send patches to do =
that
shortly.

Neil

> --=20
> Leandro Lucarella (AKA luca)                     http://llucax.com.ar=
/
> ---------------------------------------------------------------------=
-
> GPG Key: 5F5A8D05 (F8CD F9A7 BF00 5431 4145  104C 949E BFB6 5F5A 8D05=
)
> ---------------------------------------------------------------------=
-
> CARANCHO OBNUBILADO APARECE EN PARQUE CHACABUCO!
> 	-- Cr=F3nica TV
>=20
