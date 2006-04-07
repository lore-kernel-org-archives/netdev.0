From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 14/21] orinoco: fix BAP0 offset error after several days of operation
Date: Fri, 07 Apr 2006 04:10:47 -0400
Message-ID: <20060407081047.16107.85223.stgit@dv.roinet.com>
References: <20060407081019.16107.67672.stgit@dv.roinet.com>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
In-Reply-To: <20060407081019.16107.67672.stgit-fdEtzkpK75rby3iVrkZq2A@public.gmane.org>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

From: Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>

After several days of operation of Netgear MA311 card, the card becomes
to seek improperly and needs reset. This patch tries to reset the card
when this situation occurs.

Mar  9 06:45:16 berkeley kernel: wlan0: Error -5 writing packet to BAP
Mar  9 06:45:16 berkeley kernel: hermes @ f992a000: BAP0 offset error: re=
g=3D0x4044 id=3D0x128 offset=3D0x44
Mar  9 06:45:16 berkeley kernel: wlan0: Error -5 writing packet to BAP
Mar  9 06:45:16 berkeley kernel: hermes @ f992a000: BAP0 offset error: re=
g=3D0x4044 id=3D0x128 offset=3D0x44
(etc.)

A more detailed description of the problem can be found at
https://bugzilla.novell.com/show_bug.cgi?id=3D154773
The same problem with different card is reported at
http://sourceforge.net/mailarchive/message.php?msg_id=3D14597046

Signed-off-by: Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>
Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
---

 drivers/net/wireless/orinoco.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoc=
o.c
index 4d63738..80cf6fb 100644
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -536,6 +536,8 @@ static int orinoco_xmit(struct sk_buff *
 	return NETDEV_TX_OK;
=20
  busy:
+	if (err =3D=3D -EIO)
+		schedule_work(&priv->reset_work);
 	orinoco_unlock(priv, &flags);
 	return NETDEV_TX_BUSY;
 }



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
that extends applications into web and mobile media. Attend the live webc=
ast
and join the prime developer group breaking into this new coding territor=
y!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=3D=
121642
