From: Madalin-Cristian Bucur <madalin.bucur@nxp.com>
Subject: RE: [PATCH net-next v6 02/10] dpaa_eth: add support for DPAA Ethernet
Date: Mon, 7 Nov 2016 16:59:14 +0000
Message-ID: <AM4PR04MB16042515F3D8DD0EF54219A9ECA70@AM4PR04MB1604.eurprd04.prod.outlook.com>
References: <AM4PR04MB16049FF6E433DA445828A855ECA70@AM4PR04MB1604.eurprd04.prod.outlook.com>
 <20161107.105500.43380129278294700.davem@davemloft.net>
 <AM4PR04MB1604B2393D5CE6607204800EECA70@AM4PR04MB1604.eurprd04.prod.outlook.com>
 <20161107.113941.669208733868640796.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "pebolle@tiscali.nl" <pebolle@tiscali.nl>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "ppc@mindchasers.com" <ppc@mindchasers.com>,
 "oss@buserror.net" <oss@buserror.net>, "joe@perches.com" <joe@perches.com>,
 "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20161107.113941.669208733868640796.davem@davemloft.net>
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

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, November 07, 2016 6:40 PM
>=20
> From: Madalin-Cristian Bucur <madalin.bucur@nxp.com>
> Date: Mon, 7 Nov 2016 16:32:16 +0000
>=20
> >> From: David Miller [mailto:davem@davemloft.net]
> >> Sent: Monday, November 07, 2016 5:55 PM
> >>
> >> From: Madalin-Cristian Bucur <madalin.bucur@nxp.com>
> >> Date: Mon, 7 Nov 2016 15:43:26 +0000
> >>
> >> >> From: David Miller [mailto:davem@davemloft.net]
> >> >> Sent: Thursday, November 03, 2016 9:58 PM
> >> >>
> >> >> Why?  By clearing this, you disallow an important fundamental way t=
o
> >> >> do performane testing, via pktgen.
> >> >
> >> > The Tx path in DPAA requires one to insert a back-pointer to the skb
> >> > into
> >> > the Tx buffer. On the Tx confirmation path the back-pointer in the
> >> > buffer
> >> > is used to release the skb. If Tx buffer is shared we'd alter the
> >> > back-pointer
> >> > and leak/double free skbs. See also
> >>
> >> Then have your software state store an array of SKB pointers, one for
> each
> >> TX ring entry, just like every other driver does.
> >
> > There is no Tx ring in DPAA. Frames are send out on QMan HW queues
> > towards the FMan for Tx and then received back on Tx confirmation queue=
s
> > for cleanup.
> > Array traversal would for sure cost more than using the back-pointer.
> > Also, we can now process confirmations on a different core than the one
> > doing Tx,
> > we'd have to keep the arrays percpu and force the Tx conf on the same
> > core. Or add locks.
>=20
> Report back an integer index, like every scsi driver out there which
> completes tagged queued block I/O operations asynchronously.  You can
> associate the array with a specific TX confirmation queue.

>From HW? It only gives you back the buffer start address (plus length, etc)=
.
"buff_2_skb()" needs to be solved in SW, expensively using array (lists? As
the number of frames in flight can be large/variable) or cheaply with the b=
ack
pointer. The back-pointer approach has its tradeoffs: no shared skbs, impos=
ed
non-zero needed_headroom.
