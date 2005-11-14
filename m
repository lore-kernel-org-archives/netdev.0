From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [BUG] netpoll is unable to handle skb's using packet split
Date: Mon, 14 Nov 2005 13:15:38 -0800
Message-ID: <9929d2390511141315t2fb15b2aucbbebcbe4cec7ef1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932135AbVKNVPl@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	mpm@selenic.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When using packet split, netpoll times out when doing a netdump.

Server logs:
--netdump[14973]: Got too many timeouts in handshaking, ignoring
client 172.0.2.250
--netdump[14973]: Got too many timeouts waiting for SHOW_STATUS for
client 172.0.2.250, rebooting it.

When packet split is not used, netpoll dumps correctly.  This was
reproduced using the initial setup:

HP DL380G3 (Server)
RHEL4 U1
7170 NIC
e1000 driver

HP DL380G4 (Client)
RHEL3 U5
7170 NIC
e1000 driver

We also tested using the latest RHEL4 U2 on the client, with the same results.

Netpoll does not appear to be able to handle skb's using packet split,
a possible resolution would be to test for packet split and to use
skb_linearize() in netpoll to resolve the issue.

--
Cheers,
Jeff
