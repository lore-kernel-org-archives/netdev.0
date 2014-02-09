From: Thomas Glanzmann <thomas@glanzmann.de>
Subject: RFC: Set MSG_MORE in iscsit_fe_sendpage_sg to avoid sending multiple
 TCP packets instead of one
Date: Sun, 9 Feb 2014 08:40:27 +0100
Message-ID: <20140209074027.GA8105@glanzmann.de>
References: <1391867404.10160.88.camel@edumazet-glaptop2.roam.corp.google.com>
 <1391868816.10160.93.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140208141905.GG20512@glanzmann.de>
 <1391869805.10160.97.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140208150001.GI20512@glanzmann.de>
 <1391871986.10160.105.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140208165732.GB22359@glanzmann.de>
 <1391879318.10160.108.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140208171531.GA23798@glanzmann.de>
 <1391886759.10160.114.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Ogness <john.ogness@linutronix.de>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	target-devel <target-devel@vger.kernel.org>,
	Linux Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1391886759.10160.114.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Eric,
I took the liberty to test and make your patch compile by adding the
following changeset:

--- a/drivers/target/iscsi/iscsi_target_parameters.c
+++ b/drivers/target/iscsi/iscsi_target_parameters.c
@@ -79,7 +79,7 @@ int iscsi_login_tx_data(
         */
        conn->if_marker += length;

-       tx_sent = tx_data(conn, &iov[0], iov_cnt, length);
+       tx_sent = tx_data(conn, &iov[0], iov_cnt, length, 0);
        if (tx_sent != length) {
                pr_err("tx_data returned %d, expecting %d.\n",
                                tx_sent, length);

Hello Nab,
please consider this for upstream. If I should clean it up in two patches:

        - One patch to change the interface iscsit_do_tx_data and tx_data

        - Another patch who uses the newly introduced interface

Let me know. This is how I would have normally done it. I set Eric as author
but singed it off and tested it. My testbed was: Using ESXi 5.5.0 GA to create
a 500 GB VMFS filesystem via iSCSI.

Cheers,
        Thomas
