From: Johan Hovold <jhovold@gmail.com>
Subject: [PATCH 0/2] bluetooth: fix NULL-pointer dereferences
Date: Wed,  7 Mar 2012 17:01:58 +0100
Message-ID: <1331136120-27075-1-git-send-email-jhovold@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Johan Hovold <jhovold@gmail.com>
To: Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, 

These patches fixes two races in hci_ldisc and hci_core which can lead to
NULL-pointer dereferences.

The first one is 100% reproducible on 3.2 as well as 3.3-rc6 and needs to be
backported to all stable kernels as the offending code has been around for
quite some time.

The second one is 100% reproducible on 3.3-rc6 but I haven't seen it on 3.2 or
earlier, but as far as I can see it could be possibly to trigger it at least on
3.0 and later.


Thanks,
Johan

Johan Hovold (2):
  bluetooth: hci_ldisc: fix NULL-pointer dereference on tty_close
  bluetooth: hci_core: fix NULL-pointer dereference at unregister

 drivers/bluetooth/hci_ldisc.c |    2 +-
 include/net/bluetooth/hci.h   |    1 +
 net/bluetooth/hci_core.c      |    7 +++++++
 3 files changed, 9 insertions(+), 1 deletions(-)

-- 
1.7.8.4
