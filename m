From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH V6 8/8] hvsock: introduce Hyper-V Socket feature
Date: Wed, 27 Jan 2016 02:48:20 +0000
Message-ID: <e2183eeeaacd4b938813098da7531b69@HKXPR3004MB0088.064d.mgd.msft.net>
References: <1453801515-3501-1-git-send-email-decui@microsoft.com>
 <20160126102412.GA19626@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "pebolle@tiscali.nl" <pebolle@tiscali.nl>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "stephen@networkplumber.org" <stephen@networkplumber.org>,
 "stefanha@redhat.com" <stefanha@redhat.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "davem@davemloft.net" <davem@davemloft.net>,
 "dan.carpenter@oracle.com" <dan.carpenter@oracle.com>
To: Olaf Hering <olaf@aepfle.de>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20160126102412.GA19626@aepfle.de>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

> From: Olaf Hering [mailto:olaf@aepfle.de]
> Sent: Tuesday, January 26, 2016 18:24
> To: Dexuan Cui <decui@microsoft.com>
> Cc: gregkh@linuxfoundation.org; davem@davemloft.net;
> stephen@networkplumber.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; driverdev-devel@linuxdriverproject.org;
> apw@canonical.com; jasowang@redhat.com; KY Srinivasan
> <kys@microsoft.com>; vkuznets@redhat.com; pebolle@tiscali.nl;
> stefanha@redhat.com; dan.carpenter@oracle.com
> Subject: Re: [PATCH V6 8/8] hvsock: introduce Hyper-V Socket feature
> 
> On Tue, Jan 26, Dexuan Cui wrote:
> 
> > +#define AF_MAX		42	/* For now.. */
> 
> Maybe net/core/sock.c needs additional strings for the new socket?
> 
> Olaf
Olaf, Thanks for the reminder!

I'll add a new patch like this:

diff --git a/net/core/sock.c b/net/core/sock.c
index 6c1c8bc..3c0aedb 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -221,7 +221,8 @@ static const char *const af_family_key_strings[AF_MAX+1] = {
   "sk_lock-AF_TIPC"  , "sk_lock-AF_BLUETOOTH", "sk_lock-IUCV"        ,
   "sk_lock-AF_RXRPC" , "sk_lock-AF_ISDN"     , "sk_lock-AF_PHONET"   ,
   "sk_lock-AF_IEEE802154", "sk_lock-AF_CAIF" , "sk_lock-AF_ALG"      ,
-  "sk_lock-AF_NFC"   , "sk_lock-AF_VSOCK"    , "sk_lock-AF_MAX"
+  "sk_lock-AF_NFC"   , "sk_lock-AF_VSOCK"    , "sk_lock-AF_HYPERV"
+  "sk_lock-AF_MAX"
 };
 static const char *const af_family_slock_key_strings[AF_MAX+1] = {
   "slock-AF_UNSPEC", "slock-AF_UNIX"     , "slock-AF_INET"     ,
@@ -237,7 +238,8 @@ static const char *const af_family_slock_key_strings[AF_MAX+1] = {
   "slock-AF_TIPC"  , "slock-AF_BLUETOOTH", "slock-AF_IUCV"     ,
   "slock-AF_RXRPC" , "slock-AF_ISDN"     , "slock-AF_PHONET"   ,
   "slock-AF_IEEE802154", "slock-AF_CAIF" , "slock-AF_ALG"      ,
-  "slock-AF_NFC"   , "slock-AF_VSOCK"    ,"slock-AF_MAX"
+  "slock-AF_NFC"   , "slock-AF_VSOCK"    ,"slock-AF_HYPERV"
+  "slock-AF_MAX"
 };
 static const char *const af_family_clock_key_strings[AF_MAX+1] = {
   "clock-AF_UNSPEC", "clock-AF_UNIX"     , "clock-AF_INET"     ,
@@ -253,7 +255,8 @@ static const char *const af_family_clock_key_strings[AF_MAX+1] = {
   "clock-AF_TIPC"  , "clock-AF_BLUETOOTH", "clock-AF_IUCV"     ,
   "clock-AF_RXRPC" , "clock-AF_ISDN"     , "clock-AF_PHONET"   ,
   "clock-AF_IEEE802154", "clock-AF_CAIF" , "clock-AF_ALG"      ,
-  "clock-AF_NFC"   , "clock-AF_VSOCK"    , "clock-AF_MAX"
+  "clock-AF_NFC"   , "clock-AF_VSOCK"    , "clock-AF_HYPERV"
+  "clock-AF_MAX"
 };

 /*

Thanks,
-- Dexuan
