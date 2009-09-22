From: John Linn <John.Linn@xilinx.com>
Subject: RE: [PATCH] net: xilinx_emaclite: Fix problem with first incoming
	packet
Date: Tue, 22 Sep 2009 10:56:27 -0600
Message-ID: <20090922165612.584554A8052@mail195-sin.bigfish.com>
References: <fac40d47-5b19-4225-9fee-f7a058851fc0@SG2EHSMHS017.ehs.local>
	<fa686aa40909220953g708445d9s9c25bd839cc2dd2e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Michal Simek <monstr@monstr.eu>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, Sadanand Mutyala <sadanan@xilinx.com>,
	davem@davemloft.net
To: "Grant Likely" <grant.likely@secretlab.ca>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-Class: urn:content-classes:message
In-Reply-To: <fa686aa40909220953g708445d9s9c25bd839cc2dd2e@mail.gmail.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

Thanks Grant, I wondered about that myself.

> -----Original Message-----
> From: glikely@secretlab.ca [mailto:glikely@secretlab.ca] On Behalf Of Gra=
nt Likely
> Sent: Tuesday, September 22, 2009 10:54 AM
> To: John Linn
> Cc: netdev@vger.kernel.org; davem@davemloft.net; linuxppc-dev@ozlabs.org;=
 jwboyer@linux.vnet.ibm.com;
> Sadanand Mutyala; Michal Simek
> Subject: Re: [PATCH] net: xilinx_emaclite: Fix problem with first incomin=
g packet
> =

> On Tue, Sep 22, 2009 at 8:24 AM, John Linn <john.linn@xilinx.com> wrote:
> > From: Michal Simek <monstr@monstr.eu>
> >
> > You can't ping the board or connect to it unless you send
> > any packet out from board.
> >
> > Tested-by: John Williams <john.williams@petalogix.com>
> > Signed-off-by: Michal Simek <monstr@monstr.eu>
> > Acked-by: John Linn <john.linn@xilinx.com>
> =

> John, Since this patch is being *sent* by you, then you should use a
> "signed-off-by" tag instead because it actually passed through your
> hands.
> =

> Oh, and:
> Acked-by: Grant Likely <grant.likely@secretlab.ca>
> =

> > ---
> > =A0drivers/net/xilinx_emaclite.c | =A0 =A07 ++-----
> > =A01 files changed, 2 insertions(+), 5 deletions(-)
> >
> > diff --git a/drivers/net/xilinx_emaclite.c b/drivers/net/xilinx_emaclit=
e.c
> > index dc22782..83a044d 100644
> > --- a/drivers/net/xilinx_emaclite.c
> > +++ b/drivers/net/xilinx_emaclite.c
> > @@ -134,18 +134,15 @@ static void xemaclite_enable_interrupts(struct ne=
t_local *drvdata)
> > =A0 =A0 =A0 =A0}
> >
> > =A0 =A0 =A0 =A0/* Enable the Rx interrupts for the first buffer */
> > - =A0 =A0 =A0 reg_data =3D in_be32(drvdata->base_addr + XEL_RSR_OFFSET);
> > =A0 =A0 =A0 =A0out_be32(drvdata->base_addr + XEL_RSR_OFFSET,
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reg_data | XEL_RSR_RECV_IE_MASK);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0XEL_RSR_RECV_IE_MASK);
> >
> > =A0 =A0 =A0 =A0/* Enable the Rx interrupts for the second Buffer if
> > =A0 =A0 =A0 =A0 * configured in HW */
> > =A0 =A0 =A0 =A0if (drvdata->rx_ping_pong !=3D 0) {
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 reg_data =3D in_be32(drvdata->base_addr +=
 XEL_BUFFER_OFFSET +
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0XE=
L_RSR_OFFSET);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0out_be32(drvdata->base_addr + XEL_BUFFER=
_OFFSET +
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 XEL_RSR_OFFSET,
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reg_data | XEL_RSR_REC=
V_IE_MASK);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0XEL_RSR_RECV_IE_MASK);
> > =A0 =A0 =A0 =A0}
> >
> > =A0 =A0 =A0 =A0/* Enable the Global Interrupt Enable */
> > --
> > 1.6.2.1
> >
> >
> >
> > This email and any attachments are intended for the sole use of the nam=
ed recipient(s) and
> contain(s) confidential information that may be proprietary, privileged o=
r copyrighted under
> applicable law. If you are not the intended recipient, do not read, copy,=
 or forward this email
> message or any attachments. Delete this email message and any attachments=
 immediately.
> >
> >
> >
> =

> =

> =

> --
> Grant Likely, B.Sc., P.Eng.
> Secret Lab Technologies Ltd.


This email and any attachments are intended for the sole use of the named r=
ecipient(s) and contain(s) confidential information that may be proprietary=
, privileged or copyrighted under applicable law. If you are not the intend=
ed recipient, do not read, copy, or forward this email message or any attac=
hments. Delete this email message and any attachments immediately.
