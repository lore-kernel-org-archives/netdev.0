From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH v3 0/5] net: dsa: complete and fix the dsa unbinding
Date: Tue, 6 Oct 2015 15:39:42 +0100
Message-ID: <5613DD2E.1070209@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com, Andrew Lunn <andrew@lunn.ch>,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nbd@openwrt.org,
	sergei.shtylyov@cogentembedded.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In order to cleanly unbind the dsa core, either as a module removal,
or a platform device unbind, switch the allocation the their devm_
counterparts and complete the destroy functions.

First, the missing kfree were added, the remove function were
completed then kfree were removed in favor to devm_ calls.

The last patch is an way to cleanly exit the probe when no
switch is found in the discover process.

The patches are based on the current net.

v3:
 - make checkpatch happy with 1/5 & 5/5
 - fix 5/5 exit path with a goto

Neil Armstrong (5):
  net: dsa: add missing kfree on remove
  net: dsa: add missing dsa_switch mdiobus remove
  net: dsa: complete dsa_switch_destroy
  net: dsa: switch to devm_ calls and remove kfree calls
  net: dsa: exit probe if no switch were found

 net/dsa/dsa.c | 70 +++++++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 59 insertions(+), 11 deletions(-)

-- 
1.9.1
