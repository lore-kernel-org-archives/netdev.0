From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH 15/19] sunrpc: don't warn for unused variable 'buf'
Date: Fri, 25 Jan 2013 23:45:25 +0000
Message-ID: <201301252345.25829.arnd@arndb.de>
References: <1359123276-15833-1-git-send-email-arnd@arndb.de> <1359153858-31992-16-git-send-email-arnd@arndb.de> <4FA345DA4F4AE44899BD2B03EEEC2FA91833C205@sacexcmbx05-prd.hq.netapp.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"J. Bruce Fields" <bfields-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Myklebust, Trond" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA91833C205-UCI0kNdgLrHLJmV3vhxcH3OR4cbS7gtM96Bgd4bDwmQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 25 January 2013, Myklebust, Trond wrote:
> > -----Original Message-----
> > From: Arnd Bergmann [mailto:arnd-r2nGTMty4D4@public.gmane.org]
> > Marking it as __maybe_unused avoids a harmless gcc warning.
> 
> Alternatively, just declare it using the RPC_IFDEBUG() macro.

Right, makes sense: that's more consistent with other functions
doing the same thing. Thanks for taking a look.

	Arnd

8<----

>From 3b2baeac061bd60dbf14bb61bcc03cbd64c85ac4 Mon Sep 17 00:00:00 2001
From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Date: Mon, 26 Nov 2012 22:46:26 +0000
Subject: [PATCH] sunrpc: don't warn for unused variable 'buf'

When RPC_DEBUG is unset, the dprintk() macro does nothing,
causing the 'buf' variable in svc_printk to become unused.
Enclosing it in RPC_IFDEBUG avoids a harmless gcc warning.

Without this patch, building at91_dt_defconfig results in:

net/sunrpc/svc.c: In function 'svc_printk':
net/sunrpc/svc.c:1051:7: warning: unused variable 'buf' [-Wunused-variable]

Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Cc: "J. Bruce Fields" <bfields-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index dbf12ac..9485e66 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1047,7 +1047,7 @@ void svc_printk(struct svc_rqst *rqstp, const char *fmt, ...)
 {
 	struct va_format vaf;
 	va_list args;
-	char 	buf[RPC_MAX_ADDRBUFLEN];
+	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
 
 	va_start(args, fmt);
 


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
