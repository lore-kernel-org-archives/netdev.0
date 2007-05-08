From: Jiri Kosina <jikos@jikos.cz>
Subject: Re: Getting make net/built-in.o Error with 2.6.21.1
	Build
Date: Tue, 8 May 2007 18:23:57 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0705081815130.16923@twin.jikos.cz>
References: <463FB6B0.3070005@pcburn.com>
	<a781481a0705071725i1d802dfejbcdaca4ab0a1ff55@mail.gmail.com>
	<Pine.LNX.4.64.0705081740550.16923@twin.jikos.cz>
	<a781481a0705080905l609dc925s93357e6eb0d4c318@mail.gmail.com>
Reply-To: BlueZ development <bluez-devel@lists.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chris@pcburn.com,
	bluez-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Satyam Sharma <satyam.sharma@gmail.com>,
	Marcel Holtmann <marcel@holtmann.org>
Return-path: <bluez-devel-bounces@lists.sourceforge.net>
In-Reply-To: <a781481a0705080905l609dc925s93357e6eb0d4c318@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=bluez-devel>
List-Post: <mailto:bluez-devel@lists.sourceforge.net>
List-Help: <mailto:bluez-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: bluez-devel-bounces@lists.sourceforge.net
Errors-To: bluez-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, 8 May 2007, Satyam Sharma wrote:

> Sure, my aim here was to only solve the _build breakage_ by fixing the 
> Kconfig for this module (that used code from another kernel module 
> without listing it in its dependencies). If, as you say, the real 
> solution is that we should actually be taking out the offending call to 
> the other module itself, then please go ahead -- I don't know much about 
> the Bluetooth / HIDP subsytem anyway.

Converting the hid-ff drivers to be also transport-independent is on my 
TODO list, but it didn't happen yet.

Marcel - are you aware of any devices currently supported by USB HID 
force-feedback code, which have a bluetooth version, please? 

I'd propose the patch below, until I make the usbhid force-feedback code 
transport independent. Thanks.



From: Jiri Kosina <jkosina@suse.cz>

[Bluetooth] HIDP - don't initialize force feedback

The current implementation of force feedback for HID devices is 
USB-transport only and therefore calling hid_ff_init() from hidp code is 
not going to work (plus it creates unwanted dependency of hidp on usbhid). 
Remove the hid_ff_init() until either the hid-ff is made 
transport-independent, or at least support for bluetooth transport is 
added.

Signed-off-by: Jiri Kosina <jkosina@suse.cz>

diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index d342e89..3e77e81 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -737,10 +737,8 @@ static inline void hidp_setup_hid(struct
 	list_for_each_entry(report, &hid->report_enum[HID_FEATURE_REPORT].report_list, list)
 		hidp_send_report(session, report);
 
-	if (hidinput_connect(hid) == 0) {
+	if (hidinput_connect(hid) == 0)
 		hid->claimed |= HID_CLAIMED_INPUT;
-		hid_ff_init(hid);
-	}
 }
 
 int hidp_add_connection(struct hidp_connadd_req *req, struct socket *ctrl_sock, struct socket *intr_sock)

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
