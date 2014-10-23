From: Fabian Frederick <fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH 1/1 net-next] Bluetooth: fix shadow warning in
 hci_disconnect()
Date: Thu, 23 Oct 2014 19:30:53 +0200 (CEST)
Message-ID: <20326343.74480.1414085453988.open-xchange@webmail.nmp.skynet.be>
References: <1414081365-6461-1-git-send-email-fabf@skynet.be> <2F67F6E8-CA99-4998-AE68-89E60D62C39D@holtmann.org>
Reply-To: Fabian Frederick <fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	BlueZ development <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2F67F6E8-CA99-4998-AE68-89E60D62C39D-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



> On 23 October 2014 at 18:29 Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org> wro=
te:
>
>
> Hi Fabian,
>
> > use cpr for hci_cp_read_clock_offset instead of cp
> > (already defined above).
> >
> > Signed-off-by: Fabian Frederick <fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>
> > ---
> > net/bluetooth/hci_conn.c | 6 +++---
> > 1 file changed, 3 insertions(+), 3 deletions(-)
> >
> > diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
> > index b9517bd..6151e09 100644
> > --- a/net/bluetooth/hci_conn.c
> > +++ b/net/bluetooth/hci_conn.c
> > @@ -141,10 +141,10 @@ int hci_disconnect(struct hci_conn *conn, __u=
8 reason)
> >=C2=A0 =C2=A0 =C2=A0 */
> >=C2=A0 =C2=A0 =C2=A0if (conn->type =3D=3D ACL_LINK && conn->role =3D=
=3D HCI_ROLE_MASTER) {
> >=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct hci_dev *hdev=
 =3D conn->hdev;
> > -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct hci_cp_read_clock_=
offset cp;
> > +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct hci_cp_read_clock_=
offset cpr;
> >
> > -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cp.handle =3D cpu_to_le16=
(conn->handle);
> > -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0hci_send_cmd(hdev, HCI_OP=
_READ_CLOCK_OFFSET, sizeof(cp), &cp);
> > +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cpr.handle =3D cpu_to_le1=
6(conn->handle);
> > +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0hci_send_cmd(hdev, HCI_OP=
_READ_CLOCK_OFFSET, sizeof(cpr), &cpr);
>
> valid change, but I do not like cpr as variable name. We need to come=
 up with
> a better one. There are other places in the code where we had the sam=
e thing.
> Please have a look there.
>
> Regards
>
> Marcel
>

Hi Marcel,

=C2=A0 Maybe read_cp (like commit c1f23a2bfc89 with struct hci_cp_auth_=
requested
auth_cp) ?

Regards,
=46abian
