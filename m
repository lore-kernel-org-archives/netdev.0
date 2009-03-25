From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ucc_geth: Move freeing of TX packets to NAPI context.
Date: Wed, 25 Mar 2009 14:40:41 -0700 (PDT)
Message-ID: <20090325.144041.128558998.davem@davemloft.net>
References: <1237987849.2194.9.camel@gentoo-jocke.transmode.se>
	<49CA39EA.6020208@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: leoli@freescale.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: dada1@cosmosbay.com
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <49CA39EA.6020208@cosmosbay.com>
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

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 25 Mar 2009 15:04:26 +0100

> Joakim Tjernlund a =E9crit :
> > +	/* Tx event processing */
> > +	spin_lock(&ugeth->lock);
> > +	for (i =3D 0; i < ug_info->numQueuesTx; i++) {
> > +		ucc_geth_tx(ugeth->dev, i);
> > +	}
> > +	spin_unlock(&ugeth->lock);
> > +
> =

> Why tx completions dont change "howmany" ?
> It seems strange you changed UCC_GETH_DEV_WEIGHT if not taking into accou=
nt tx event above...

He should leave howmany alone for TX work and use a weight
value of 64 just like most other drivers in the tree do.

Due to the abuse and random ignorant fiddling of the
weight value, I am going to make it something the core
rather than drivers choose.
