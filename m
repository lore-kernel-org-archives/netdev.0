From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: rfkill regression in net-next-2.6
Date: Mon, 15 Jun 2009 14:24:46 +0200
Message-ID: <1245068686.23912.0.camel@johannes.local>
References: <20090604152011.GC2839@tuxdriver.com>
	 <20090607.033751.191866033.davem@davemloft.net>
	 <4A2BCC41.1060508@hartkopp.net> <20090607145830.GA2736@tuxdriver.com>
	 <4A2BD8A5.4040302@hartkopp.net>
	 <1244388583.23850.87.camel@localhost.localdomain>
	 <4A34BAB9.9000104@hartkopp.net>  <20090615120422.GA2729@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090615120422.GA2729-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2009-06-15 at 08:04 -0400, John W. Linville wrote:
> On Sun, Jun 14, 2009 at 10:54:17AM +0200, Oliver Hartkopp wrote:
> 
> > Any idea what changed in net-next-2.6 that could produce this behaviour?
> 
> The rfkill subsystem rewrite would seem suspect... :-)

Maybe this fixes it?

johannes

--- wireless-testing.orig/drivers/platform/x86/dell-laptop.c	2009-06-15 14:23:25.000000000 +0200
+++ wireless-testing/drivers/platform/x86/dell-laptop.c	2009-06-15 14:23:35.000000000 +0200
@@ -177,7 +177,7 @@ dell_send_request(struct calling_interfa
 static int dell_rfkill_set(void *data, bool blocked)
 {
 	struct calling_interface_buffer buffer;
-	int disable = blocked ? 0 : 1;
+	int disable = blocked ? 1 : 0;
 	unsigned long radio = (unsigned long)data;
 
 	memset(&buffer, 0, sizeof(struct calling_interface_buffer));


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
