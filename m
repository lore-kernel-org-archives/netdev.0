From: Sergey Vlasov <vsu@altlinux.ru>
Subject: Re: Last night Linus bk - netfilter busted?
Date: Fri, 11 Mar 2005 22:27:01 +0300
Message-ID: <20050311222701.216aba43.vsu@altlinux.ru>
References: <200503110223.34461.dtor_core@ameritech.net>
	<4231A498.4020101@trash.net>
	<20050311105136.2a5e4ddc.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="pgp-sha1";
 boundary="Signature=_Fri__11_Mar_2005_22_27_01_+0300_lu/w9Mn=IHAiPcq/"
Cc: Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com,
	dtor_core@ameritech.net, netfilter-devel@lists.netfilter.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050311105136.2a5e4ddc.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__11_Mar_2005_22_27_01_+0300_lu/w9Mn=IHAiPcq/
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

On Fri, 11 Mar 2005 10:51:36 -0800 David S. Miller wrote:

> On Fri, 11 Mar 2005 15:00:56 +0100
> Patrick McHardy <kaber@trash.net> wrote:
> 
> > Works fine here. You could try if reverting one of these two patches
> > helps (second one only if its a SMP box).
> > 
> > ChangeSet@1.2010, 2005-03-09 20:28:17-08:00, bdschuym@pandora.be
> >    [NETFILTER]: Reduce call chain length in netfilter (take 2)
> 
> It's this change, I know it is, because Linus sees the same problem
> on his workstation.
> 
> You wouldn't happen to be seeing this problem on a PPC box would
> you?  Since Linus's machine is a PPC machine too, that would support
> my theory that this could be a compiler issue on that platform.
> 
> Damn, wait, Patrick, I think I know what's happening.  The iptables
> IPT_* verdicts are dependant upon the NF_* values, and they don't
> cope with Bart's changes I bet.  Can you figure out what the exact
> error would be?  This kind of issue would explain the looping inside
> of ipt_do_table(), wouldn't it?

This is not just some buggy code - that patch also breaks interfaces:

include/linux/netfilter_ipv4/ip_tables.h:
#define IPT_RETURN (-NF_MAX_VERDICT - 1)

And this value is visible in userspace.  Therefore we cannot modify
NF_MAX_VERDICT without breaking all existing iptables binaries.

--Signature=_Fri__11_Mar_2005_22_27_01_+0300_lu/w9Mn=IHAiPcq/
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFCMfEIW82GfkQfsqIRAlL4AJ40CH8yoWTNI8F/+isZHwf4CGqq4ACeOQWL
xiFAh8jgzFt1YDmzWnc8Oc8=
=RHYq
-----END PGP SIGNATURE-----

--Signature=_Fri__11_Mar_2005_22_27_01_+0300_lu/w9Mn=IHAiPcq/--
