From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH] powerpc: ibmveth: Harden driver initilisation for kexec
Date: Fri, 3 Mar 2006 13:11:56 +1100
Message-ID: <200603031312.00787.michael@ellerman.id.au>
References: <20060131041055.5623C68A46@ozlabs.org>
	<44074A22.8060705@us.ibm.com> <44079627.6070100@pobox.com>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0894499387=="
Cc: Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>, anton@samba.org
Return-path: <linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: linuxppc64-dev@ozlabs.org
In-Reply-To: <44079627.6070100@pobox.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Mime-version: 1.0
Sender: linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc64-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

--===============0894499387==
Content-Type: multipart/signed;
  boundary="nextPart1358239.mlMNTdhI47";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart1358239.mlMNTdhI47
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Fri, 3 Mar 2006 12:04, Jeff Garzik wrote:
> Santiago Leon wrote:
> > From: Michael Ellerman <michael@ellerman.id.au>
> >
> > After a kexec the veth driver will fail when trying to register with the
> > Hypervisor because the previous kernel has not unregistered.
> >
> > So if the registration fails, we unregister and then try again.
> >
> > Signed-off-by: Michael Ellerman <michael@ellerman.id.au>
> > Acked-by: Anton Blanchard <anton@samba.org>
> > Signed-off-by: Santiago Leon <santil@us.ibm.com>
> > ---
> >
> >  drivers/net/ibmveth.c |   32 ++++++++++++++++++++++++++------
> >  1 files changed, 26 insertions(+), 6 deletions(-)
> >
> > Looks good to me, and has been around for a couple of months.
>
> This seems completely bonkers to me:
>
> 	are resources available?
> 	if no
> 		free resources
> 		try again

I'm not sure I follow, are you suggesting we do the h_free_logical_lan()=20
unconditionally, followed by h_register_logical_lan() ??

If that's what you mean, I didn't do it that way because it would effect th=
e=20
normal code path. This patch only modifies the behaviour if we fail to=20
register the adapter. I'm much more comfortable changing the failure case=20
than the default.

cheers

=2D-=20
Michael Ellerman
IBM OzLabs

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--nextPart1358239.mlMNTdhI47
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBEB6XwdSjSd0sB4dIRAr81AJ9m++Ouyn0i6+BgdHHvUIqYmwOkgACgxAGY
7PZEwE67866NcJZv3eIV630=
=Hvne
-----END PGP SIGNATURE-----

--nextPart1358239.mlMNTdhI47--

--===============0894499387==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc64-dev mailing list
Linuxppc64-dev@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc64-dev

--===============0894499387==--
