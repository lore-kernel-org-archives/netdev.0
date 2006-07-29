From: Hugo Santos <hsantos@av.it.pt>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Sat, 29 Jul 2006 14:34:42 +0100
Message-ID: <20060729133442.GI8334@innerghost.net>
References: <20060728014528.GB29313@innerghost.net> <20060727.192743.39159331.davem@davemloft.net> <20060728031322.GE29313@innerghost.net> <20060727.202044.85689055.davem@davemloft.net> <20060728033132.GF29313@innerghost.net> <20060727210738.36f33436@localhost.localdomain> <20060728083433.GG29313@innerghost.net> <1154090737.5165.69.camel@jzny2>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="HuXIgs6JvY9hJs5C"
Cc: Stephen Hemminger <shemminger@osdl.org>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, kazunori@miyazawa.org,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.av.it.pt ([193.136.92.53]:57007 "EHLO av.it.pt")
	by vger.kernel.org with ESMTP id S932134AbWG2Nep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 09:34:45 -0400
To: Jamal Hadi Salim <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1154090737.5165.69.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--HuXIgs6JvY9hJs5C
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Jamal,

   Through this discussion i've identified three points: one is that
 some believe control and data should be kept synchronized; the other is
 how some (including all of the first :-) think control should remain
 inside the kernel; and finally you and me so far who believe they
 should be separated for increased flexibility. If we consider the first
 point, i would too have difficulties accepting the second one, taking
 the same considerations Stephen mentioned, where an application could
 possibly bork the kernel. So, first of all, we need to settle whether
 data really needs to be in-sync with control (already assuming the
 complexity control is gaining).

   Personally i think the answer is clear; the overall throughput
 depends on the amount of time spent in a single state. Thus, the data
 path should be well contained and depend only on the current state;
 while control executes in parallel as it's state transitions are much
 longer and might depend on multiple sub-transitions (communicating with
 peers, etc).

   Deciding whether control should remain inside the kernel or not is
 another story; as you point out, people generically don't like to
 depend on daemons. I understand this point, and i think a solution that
 would keep both parties happy would be to have the current
 functionality inside the kernel while at the same time allowing control
 daemons to take over and support additional complex features.

   I would say that the generic worries such as 'how do we handle out of
 memory', or 'what if it crashes' or even 'what if it is overloaded'
 apply both to the kernel and to a possible user-space application.

   - As this control daemon is important for the proper interaction of
     the host with the network, we would reduce it's chances of being
     OOM killed (while at the same time implementing algorithms to
     prevent DoS by state flooding);
   - Regarding the crashes, i think it is better for a system to have an
     application rather than a kernel component crash as it might be
     seamlessly restarted to recover. I would also say that the complex-
     ity of the code is the same (or worst if in the kernel) to support
     exactly the same features;
   - The overloading problem also applies to the kernel, and would be
     something that must be considered by either implementation;

   Don't forget that having this functionality in a daemon would also
 allow for easier updates (including updates without having to reboot
 your machine) besides offering a greater degree of flexibility.

   Let me also point out to any IKE daemon, where the SA/SP database is
 kept in kernel, but is provided for by the daemon using explicit
 requests by the kernel (ACQUIREs). If we consider neighbor discovery
 for instance, if configured to do so, and as an example, instead of
 sending an IPv6 NS, the kernel could netlink broadcast (or unicast to a
 specific controller) the request due to an entry being STALEd and being
 required where the daemon would then update the entry to REACHABLE.

   I'm sure some of you will continue to disagree, but i would really
 like to move this decision to the user (or system deployer).

   Hugo

--HuXIgs6JvY9hJs5C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFEy2Py7asb/itUNKwRAs67AJ9aZYxNGSdoXn7Ei62+b6fV5rQK6wCgm5Zg
8YMCfItVxv/BtxEMqP2IPm0=
=D1AU
-----END PGP SIGNATURE-----

--HuXIgs6JvY9hJs5C--
