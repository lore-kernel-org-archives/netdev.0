From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH v2 0/6] Further fix for dsa unbinding
Date: Thu, 29 Oct 2015 14:22:34 +0100
Message-ID: <56321D9A.8010109@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Frode Isaksen <fisaksen@baylibre.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This serie fixes further issues for DSA dynamic unbinding.
Frode Isaksen's patches make usage of delayed work and fixes kernel
crashes when dsa is unbind.
The other patches are simple fixes to permit cleanup and avoid netdev
related crashes.

v2: remove phy fix and add missing calls in dsa_switch_destroy
then add dedicated dsa_slave_destroy

Frode Isaksen (4):
  net: dsa: Use delayed work instead of timer+work for polling
  net: dsa: Do not reschedule polling if driver removed
  net: dsa: add missing calls in dsa_switch_destroy
  net: dsa: move dsa slave destroy code to slave.c

Neil Armstrong (2):
  net: dsa: cleanup resources upon module removal
  net: dsa: Add missing master netdev dev_put() calls

 include/net/dsa.h  |  3 +--
 net/dsa/dsa.c      | 45 +++++++++++++++++++++++----------------------
 net/dsa/dsa_priv.h |  1 +
 net/dsa/slave.c    | 10 ++++++++++
 4 files changed, 35 insertions(+), 24 deletions(-)

-- 
1.9.1
