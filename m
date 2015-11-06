From: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Subject: [PATCH] NFC: nci: Fix error check of nci_hci_create_pipe() result
Date: Fri,  6 Nov 2015 12:26:34 +0100
Message-ID: <1446809194-25993-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
To: Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Christophe Ricard <christophe.ricard-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

net/nfc/nci/hci.c: In function =E2=80=98nci_hci_connect_gate=E2=80=99:
net/nfc/nci/hci.c:679: warning: comparison is always false due to limit=
ed range of data type

In case of error, nci_hci_create_pipe() returns NCI_HCI_INVALID_PIPE,
and not a negative error code.

Correct the check to fix this.

Signed-off-by: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
---
 net/nfc/nci/hci.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/nfc/nci/hci.c b/net/nfc/nci/hci.c
index 2aedac15cb592353..a0ab26d535dca749 100644
--- a/net/nfc/nci/hci.c
+++ b/net/nfc/nci/hci.c
@@ -676,7 +676,7 @@ int nci_hci_connect_gate(struct nci_dev *ndev,
 	break;
 	default:
 		pipe =3D nci_hci_create_pipe(ndev, dest_host, dest_gate, &r);
-		if (pipe < 0)
+		if (pipe =3D=3D NCI_HCI_INVALID_PIPE)
 			return r;
 		pipe_created =3D true;
 		break;
--=20
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
