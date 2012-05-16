From: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: [RFC 05/13] USB: Allow drivers to disable hub-initiated LPM.
Date: Wed, 16 May 2012 15:45:26 -0700
Message-ID: <20120516224526.GA25856@xanatos>
References: <cover.1337203535.git.sarah.a.sharp@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gigaset307x-common-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org,
	libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <cover.1337203535.git.sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

[[Resending with a smaller Cc list]

USB 3.0 Link Power Management (LPM) is designed to allow individual
links in the bus to go into lower power states.  There are two ways a
link can enter a lower power state:

1. Device-initiated LPM.  When a USB device decides it can go into a
lower power link state, it sends a message to the parent hub, telling it
to go into either U1 or U2.  Device-initiated LPM is good for devices
that send data to the host, like communications devices.

2. Hub-initiated LPM.  After the link has been idle for a specific
amount of time, the parent hub will request that the child go into a
lower power state.  The child can refuse that request.  For example, a
USB modem may want to refuse the LPM request if it is in the middle of
receiving a text message.  Hub-initiated LPM is good for devices where
only the host initiates the data transfer, like USB printers or USB mass
storage devices.

Links will be automatically placed into higher power states by the USB
hubs and roothubs whenever the host starts a USB transmission.

Introduce a new usb_driver flag, disable_hub_initiated_lpm, that allows
drivers to disable hub-initiated LPM.

Signed-off-by: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Cc: Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>
Cc: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Hansjoerg Lipp <hjlipp-S0/GAf8tV78@public.gmane.org>
Cc: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
Cc: Karsten Keil <isdn-iHCpqvpFUx0uJkBD2foKsQ@public.gmane.org>
Cc: Oliver Neukum <oliver-Q6YOFhsQ4GZ7tPAFqOLdPg@public.gmane.org>
Cc: Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>
Cc: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Cc: Petko Manolov <petkan-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Cc: Steve Glendinning <steve.glendinning-sdUf+H5yV5I@public.gmane.org>
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Cc: "Luis R. Rodriguez" <mcgrof-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Cc: Jouni Malinen <jouni-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Cc: Vasanthakumar Thiagarajan <vthiagar-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Cc: Senthil Balasubramanian <senthilb-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Cc: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Cc: Brett Rudley <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Cc: Roland Vossen <rvossen-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Cc: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Cc: "Franky (Zhenhui) Lin" <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Cc: Kan Yan <kanyan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Cc: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
Cc: Ivo van Doorn <IvDoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Gertjan van Wingerde <gwingerde-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Helmut Schaa <helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Cc: Herton Ronaldo Krzesinski <herton-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Hin-Tak Leung <htl10-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Cc: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Cc: Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
Cc: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Cc: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: gigaset307x-common-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org
Cc: libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Cc: users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org
---
 include/linux/usb.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/usb.h b/include/linux/usb.h
index eb46077..998c276 100644
--- a/include/linux/usb.h
+++ b/include/linux/usb.h
@@ -875,6 +875,9 @@ struct usbdrv_wrap {
  *	for interfaces bound to this driver.
  * @soft_unbind: if set to 1, the USB core will not kill URBs and disable
  *	endpoints before calling the driver's disconnect method.
+ * @disable_hub_initiated_lpm: if set to 0, the USB core will not allow hubs
+ *	to initiate lower power link state transitions when an idle timeout
+ *	occurs.  Device-initiated USB 3.0 link PM will still be allowed.
  *
  * USB interface drivers must provide a name, probe() and disconnect()
  * methods, and an id_table.  Other driver fields are optional.
@@ -915,6 +918,7 @@ struct usb_driver {
 	struct usbdrv_wrap drvwrap;
 	unsigned int no_dynamic_id:1;
 	unsigned int supports_autosuspend:1;
+	unsigned int disable_hub_initiated_lpm:1;
 	unsigned int soft_unbind:1;
 };
 #define	to_usb_driver(d) container_of(d, struct usb_driver, drvwrap.driver)
-- 
1.7.9
