From: Alexander Aring <alex.aring@gmail.com>
Subject: [RFC radvd 0/2] radvd: 6lowpan 6CO testing patches
Date: Mon, 14 Dec 2015 15:07:34 +0100
Message-ID: <1450102056-23107-1-git-send-email-alex.aring@gmail.com>
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	kernel@pengutronix.de, mcr@sandelman.ca, lukasz.duda@nordicsemi.no,
	martin.gergeleit@hs-rm.de, Alexander Aring <alex.aring@gmail.com>
To: linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:38715 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914AbbLNOIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 09:08:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this patch is for testing 6CO fields in RA messages with the help of radvd.

I tested it with the following configuration and two or more nodes which can
directly reach each other.

On one node (6LBR, if more 6LBR they need to have the same context
information!):

interface lowpan0
{
        Adv6LBR on;
        AdvSendAdvert on;
        UnicastOnly on;
        AdvCurHopLimit 255;

        prefix 2001::/64 {
                AdvOnLink on;
                AdvAutonomous on;
                AdvRouterAddr on;
        };

        lowpanco {
                ctx 0 {
                        AdvContextCompressionFlag on;
                        AdvContextLength 64;
                        AdvContextPrefix 2001::;
                        AdvLifeTime 1000;
                };
        };
};

On other nodes:

interface lowpan0
{
	Adv6LBR off;
	AdvSendAdvert off;
};

Then you can see that the assigned global link 2001::/64 address will
be compressed. Tested with: ping6 and wireshark on $WPAN interface, when
using 802.15.4 6LoWPAN.

- Alex

Alexander Aring (2):
  device-linux: replace ARPHRD_IEEE802154 to ARPHRD_6LOWPAN
  radvd: rework 6CO handling

 defaults.h      |  3 +++
 device-bsd44.c  |  6 ++++++
 device-linux.c  | 46 +++++++++++++++++++++++++++++++++++++++++++---
 gram.y          | 55 ++++++++++++++++++++++++++++++++++++++++++++++---------
 pathnames.h     |  1 +
 privsep-linux.c | 55 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 process.c       | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 radvd.c         |  6 ++++++
 radvd.h         | 21 +++++++++++++++++++--
 scanner.l       |  4 +++-
 send.c          | 33 ++++++++++++++++++++++++---------
 11 files changed, 253 insertions(+), 25 deletions(-)

-- 
2.6.1
