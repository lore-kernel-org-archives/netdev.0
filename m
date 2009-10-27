From: Antti =?ISO-8859-1?Q?Kaijanm=E4ki?= <antti.kaijanmaki@nomovok.com>
Subject: [PATCH] hso: fix debug routines
Date: Tue, 27 Oct 2009 16:26:55 +0200
Message-ID: <1256653615.3591.113.camel@nomovok.homedomain>
References: <1256200578.3057.113.camel@nomovok.homedomain>
	 <20091026171550.GA24910@kroah.com>
	 <1256585855.3591.52.camel@nomovok.homedomain>
	 <20091026194058.GA25263@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jan Dumon <j.dumon@option.com>
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755001AbZJ0ObF@vger.kernel.org>
In-Reply-To: <20091026194058.GA25263@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2009-10-26 at 12:40 -0700, Greg KH wrote:
> Yes, that should be a new patch, especially as it would not be needed
> to fix older kernels for the original bug.
>=20
> So, care to send 2 patches?  The debug one isn't needed to be sent to
> the stable@kernel.org address.


Signed-off-by: Antti Kaijanm=C3=A4ki <antti.kaijanmaki@nomovok.com>
---
 drivers/net/usb/hso.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index fa4e581..746839b 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -378,7 +378,7 @@ static void dbg_dump(int line_count, const char *fu=
nc_name, unsigned char *buf,
 }
=20
 #define DUMP(buf_, len_)	\
-	dbg_dump(__LINE__, __func__, buf_, len_)
+	dbg_dump(__LINE__, __func__, (unsigned char *)buf_, len_)
=20
 #define DUMP1(buf_, len_)			\
 	do {					\
@@ -1527,7 +1527,7 @@ static void tiocmget_intr_callback(struct urb *ur=
b)
 		dev_warn(&usb->dev,
 			 "hso received invalid serial state notification\n");
 		DUMP(serial_state_notification,
-		     sizeof(hso_serial_state_notifation))
+		     sizeof(struct hso_serial_state_notification));
 	} else {
=20
 		UART_state_bitmap =3D le16_to_cpu(serial_state_notification->
--=20
1.6.3.3
