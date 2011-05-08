From: Filip Palian <s3810-9O8p/IZDBj+xgjU+5Knr6g@public.gmane.org>
Subject: Bluetooth: l2cap and rfcomm: fix 1 byte infoleak to userspace.
Date: Sun, 8 May 2011 21:57:25 +0200
Message-ID: <BANLkTik7WyQ977-+8XapTgBrVRMyexyHKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: security-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, oss-security-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	"Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

Structures "l2cap_conninfo" and "rfcomm_conninfo" have one padding
byte each. This byte in "cinfo" is copied to userspace uninitialized.

patch no.1:
-- cut --
--- a/net/bluetooth/l2cap_sock.c        2011-05-04 03:59:13.000000000 +0100
+++ b/net/bluetooth/l2cap_sock.c        2011-05-08 18:57:20.000000000 +0100
@@ -446,6 +446,7 @@ static int l2cap_sock_getsockopt_old(str
                        break;
                }

+               memset(&cinfo, 0, sizeof(cinfo));
                cinfo.hci_handle = l2cap_pi(sk)->conn->hcon->handle;
                memcpy(cinfo.dev_class, l2cap_pi(sk)->conn->hcon->dev_class, 3);

-- cut --

patch no.2:
-- cut --
--- a/net/bluetooth/rfcomm/sock.c       2011-05-04 03:59:13.000000000 +0100
+++ b/net/bluetooth/rfcomm/sock.c       2011-05-08 19:00:24.000000000 +0100
@@ -787,6 +787,7 @@ static int rfcomm_sock_getsockopt_old(st

                l2cap_sk = rfcomm_pi(sk)->dlc->session->sock->sk;

+               memset(&cinfo, 0, sizeof(cinfo));
                cinfo.hci_handle = l2cap_pi(l2cap_sk)->conn->hcon->handle;
                memcpy(cinfo.dev_class,
l2cap_pi(l2cap_sk)->conn->hcon->dev_class, 3);
-- cut --

Found by Marek Kroemeke and Filip Palian. Special thanks to Vasiliy
Kulikov for verifying this bug.


Best regards.
