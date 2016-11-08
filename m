From: "Jan Beulich" <JBeulich@suse.com>
Subject: [PATCH v3] xen-netback: prefer xenbus_scanf() over
 xenbus_gather()
Date: Tue, 08 Nov 2016 00:45:53 -0700
Message-ID: <582190C1020000780011CF5C@prv-mh.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "xen-devel" <xen-devel@lists.xenproject.org>,
        <netdev@vger.kernel.org>
To: "Paul Durrant" <paul.durrant@citrix.com>,
        "Wei Liu" <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prv-mh.provo.novell.com ([137.65.248.74]:33187 "EHLO
        prv-mh.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752502AbcKHHp5 (ORCPT
        <rfc822;groupwise-netdev@vger.kernel.org:3:1>);
        Tue, 8 Nov 2016 02:45:57 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For single items being collected this should be preferred as being more
typesafe (as the compiler can check format string and to-be-written-to
variable match) and more efficient (requiring one less parameter to be
passed).

Signed-off-by: Jan Beulich <jbeulich@suse.com>
---
v3: For consistency with other code don't consider zero an error
    (utilizing that xenbus_scanf() at present won't return zero).
v2: Avoid commit message to continue from subject.
---
 drivers/net/xen-netback/xenbus.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

--- 4.9-rc4/drivers/net/xen-netback/xenbus.c
+++ 4.9-rc4-xen-netback-prefer-xenbus_scanf/drivers/net/xen-netback/xenbus.c
@@ -889,16 +889,16 @@ static int connect_ctrl_ring(struct back
 	unsigned int evtchn;
 	int err;
 
-	err = xenbus_gather(XBT_NIL, dev->otherend,
-			    "ctrl-ring-ref", "%u", &val, NULL);
-	if (err)
+	err = xenbus_scanf(XBT_NIL, dev->otherend,
+			   "ctrl-ring-ref", "%u", &val);
+	if (err < 0)
 		goto done; /* The frontend does not have a control ring */
 
 	ring_ref = val;
 
-	err = xenbus_gather(XBT_NIL, dev->otherend,
-			    "event-channel-ctrl", "%u", &val, NULL);
-	if (err) {
+	err = xenbus_scanf(XBT_NIL, dev->otherend,
+			   "event-channel-ctrl", "%u", &val);
+	if (err < 0) {
 		xenbus_dev_fatal(dev, err,
 				 "reading %s/event-channel-ctrl",
 				 dev->otherend);
