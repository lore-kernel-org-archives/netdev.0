From: Ozgur Karatas <okaratas@member.fsf.org>
Subject: Re: [PATCH 2/2] net: wireless: fix to uses struct
Date: Thu, 22 Dec 2016 01:50:11 +0300
Message-ID: <601101482360611@web25o.yandex.ru>
References: <608881482358981@web17g.yandex.ru> <1482359625.28171.2.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: Paul Bolle <pebolle@tiscali.nl>,
        johannes <johannes@sipsolutions.net>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482359625.28171.2.camel@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


22.12.2016, 00:34, "Paul Bolle" <pebolle@tiscali.nl>:
> On Thu, 2016-12-22 at 00:23 +0200, Ozgur Karatas wrote:
>>  I compiled and didn't to errors.
>
> Really?

I'm very sorry. The "regulatory_request" is defined a static struct. I missed.

line: static struct regulatory_request core_request_world = {

I send to wrong line please can ignore last message and should be fix to as follows:

diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 5dbac37..5b70970 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -490,7 +490,7 @@ static int reg_query_builtin(const char *alpha2)
 	if (!regdom)
 		return -ENODATA;
 
-	request = kzalloc(sizeof(struct reg_regdb_apply_request), GFP_KERNEL);
+	request = kzalloc(sizeof(*reg_regdb_apply_request), GFP_KERNEL);
 	if (!request)
 		return -ENOMEM;
 
@@ -2291,7 +2291,7 @@ static int regulatory_hint_core(const char *alpha2)
 {
 	struct regulatory_request *request;
 
-	request = kzalloc(sizeof(struct regulatory_request), GFP_KERNEL);
+	request = kzalloc(sizeof(*regulatory_request), GFP_KERNEL);
 	if (!request)
 		return -ENOMEM;
 
@@ -2313,7 +2313,7 @@ int regulatory_hint_user(const char *alpha2,
 	if (WARN_ON(!alpha2))
 		return -EINVAL;
 
-	request = kzalloc(sizeof(struct regulatory_request), GFP_KERNEL);
+	request = kzalloc(sizeof(*regulatory_request), GFP_KERNEL);
 	if (!request)
 		return -ENOMEM;
 
@@ -2385,7 +2385,7 @@ int regulatory_hint(struct wiphy *wiphy, const char *alpha2)
 
 	wiphy->regulatory_flags &= ~REGULATORY_CUSTOM_REG;
 
-	request = kzalloc(sizeof(struct regulatory_request), GFP_KERNEL);
+	request = kzalloc(sizeof(*regulatory_request), GFP_KERNEL);
 	if (!request)
 		return -ENOMEM;
 
@@ -2661,7 +2661,7 @@ int regulatory_hint_found_beacon(struct wiphy *wiphy,
 	if (processing)
 		return 0;
 
-	reg_beacon = kzalloc(sizeof(struct reg_beacon), gfp);
+	reg_beacon = kzalloc(sizeof(*reg_beacon), gfp);
 	if (!reg_beacon)
 		return -ENOMEM;
 
-- 
2.1.4

> $ make net/wireless/reg.o
>   CHK include/config/kernel.release
>   CHK include/generated/uapi/linux/version.h
>   CHK include/generated/utsrelease.h
>   CHK include/generated/bounds.h
>   CHK include/generated/timeconst.h
>   CHK include/generated/asm-offsets.h
>   CALL scripts/checksyscalls.sh
>   CC net/wireless/reg.o
> net/wireless/reg.c: In function ‘regulatory_hint_core’:
> net/wireless/reg.c:2294:28: error: ‘regulatory_request’ undeclared (first use in this function)
>   request = kzalloc(sizeof(*regulatory_request), GFP_KERNEL);
>                             ^~~~~~~~~~~~~~~~~~
> net/wireless/reg.c:2294:28: note: each undeclared identifier is reported only once for each function it appears in
> net/wireless/reg.c: In function ‘regulatory_hint_user’:
> net/wireless/reg.c:2316:28: error: ‘regulatory_request’ undeclared (first use in this function)
>   request = kzalloc(sizeof(*regulatory_request), GFP_KERNEL);
>                             ^~~~~~~~~~~~~~~~~~
> net/wireless/reg.c: In function ‘regulatory_hint’:
> net/wireless/reg.c:2388:28: error: ‘regulatory_request’ undeclared (first use in this function)
>   request = kzalloc(sizeof(*regulatory_request), GFP_KERNEL);
>                             ^~~~~~~~~~~~~~~~~~
> scripts/Makefile.build:293: recipe for target 'net/wireless/reg.o' failed
> make[1]: *** [net/wireless/reg.o] Error 1
> Makefile:1640: recipe for target 'net/wireless/reg.o' failed
> make: *** [net/wireless/reg.o] Error 2

$ make M=net/wireless/
  CC      net/wireless//core.o
  CC      net/wireless//sysfs.o
  CC      net/wireless//radiotap.o
  CC      net/wireless//util.o
  CC      net/wireless//reg.o
  CC      net/wireless//scan.o
  CC      net/wireless//nl80211.o
  CC      net/wireless//mlme.o
  CC      net/wireless//ibss.o
  CC      net/wireless//sme.o
  CC      net/wireless//chan.o
  CC      net/wireless//ethtool.o
  CC      net/wireless//mesh.o
  CC      net/wireless//ap.o
  CC      net/wireless//trace.o
  CC      net/wireless//ocb.o
  LD      net/wireless//cfg80211.o
  LD      net/wireless//built-in.o
  Building modules, stage 2.
  MODPOST 0 modules

$ make net/wireless/reg.o
scripts/kconfig/conf  --silentoldconfig Kconfig
*
* Restart config...
*
*
* Memory power savings
*

> Didn't Thomas Gleixner suggest that you do a basic C course just yesterday?

I don't have a problem with C programming, So only I'm learning the kernel. 
Also, this is a lie if say "I'm expert to C".

I think be re-learned every day. wrong?

> Paul Bolle

Regards,

~ Ozgur
