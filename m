From: Madalin-Cristian Bucur <madalin.bucur@nxp.com>
Subject: RE: [PATCH net-next v6 02/10] dpaa_eth: add support for DPAA Ethernet
Date: Mon, 7 Nov 2016 16:32:16 +0000
Message-ID: <AM4PR04MB1604B2393D5CE6607204800EECA70@AM4PR04MB1604.eurprd04.prod.outlook.com>
References: <1478117854-8952-3-git-send-email-madalin.bucur@nxp.com>
 <20161103.155816.642712588084106823.davem@davemloft.net>
 <AM4PR04MB16049FF6E433DA445828A855ECA70@AM4PR04MB1604.eurprd04.prod.outlook.com>
 <20161107.105500.43380129278294700.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "pebolle@tiscali.nl" <pebolle@tiscali.nl>,
 "joakim.tjernlund@transmode.se" <joakim.tjernlund@transmode.se>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "ppc@mindchasers.com" <ppc@mindchasers.com>,
 "oss@buserror.net" <oss@buserror.net>, "joe@perches.com" <joe@perches.com>,
 "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20161107.105500.43380129278294700.davem@davemloft.net>
Content-Language: en-US
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, November 07, 2016 5:55 PM
>=20
> From: Madalin-Cristian Bucur <madalin.bucur@nxp.com>
> Date: Mon, 7 Nov 2016 15:43:26 +0000
>=20
> >> From: David Miller [mailto:davem@davemloft.net]
> >> Sent: Thursday, November 03, 2016 9:58 PM
> >>
> >> Why?  By clearing this, you disallow an important fundamental way to d=
o
> >> performane testing, via pktgen.
> >
> > The Tx path in DPAA requires one to insert a back-pointer to the skb
> into
> > the Tx buffer. On the Tx confirmation path the back-pointer in the
> buffer
> > is used to release the skb. If Tx buffer is shared we'd alter the back-
> pointer
> > and leak/double free skbs. See also
>=20
> Then have your software state store an array of SKB pointers, one for eac=
h
> TX ring entry, just like every other driver does.

There is no Tx ring in DPAA. Frames are send out on QMan HW queues towards
the FMan for Tx and then received back on Tx confirmation queues for cleanu=
p.
Array traversal would for sure cost more than using the back-pointer. Also,
we can now process confirmations on a different core than the one doing Tx,
we'd have to keep the arrays percpu and force the Tx conf on the same core.
Or add locks.

Madalin
