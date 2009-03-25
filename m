From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: Re: [PATCH] ucc_geth: Move freeing of TX packets to NAPI context.
Date: Wed, 25 Mar 2009 22:55:07 +0100
Message-ID: <OF2B9DF8FC.AFC932DD-ONC1257584.00783408-C1257584.007866EA@transmode.se>
References: <1237987849.2194.9.camel@gentoo-jocke.transmode.se>	<49CA39EA.6020208@cosmosbay.com>
	<20090325.144041.128558998.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, leoli@freescale.com,
	dada1@cosmosbay.com
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <20090325.144041.128558998.davem@davemloft.net>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote on 25/03/2009 22:40:41:
> =

> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Wed, 25 Mar 2009 15:04:26 +0100
> =

> > Joakim Tjernlund a =E9crit :
> > > +   /* Tx event processing */
> > > +   spin_lock(&ugeth->lock);
> > > +   for (i =3D 0; i < ug_info->numQueuesTx; i++) {
> > > +      ucc_geth_tx(ugeth->dev, i);
> > > +   }
> > > +   spin_unlock(&ugeth->lock);
> > > +
> > =

> > Why tx completions dont change "howmany" ?
> > It seems strange you changed UCC_GETH_DEV_WEIGHT if not taking into =

account tx event above...
> =

> He should leave howmany alone for TX work and use a weight
> value of 64 just like most other drivers in the tree do.

OK, will change this to 64.

> =

> Due to the abuse and random ignorant fiddling of the
> weight value, I am going to make it something the core
> rather than drivers choose.

Good, I had a hard time finding info how one should use it anyway. =
