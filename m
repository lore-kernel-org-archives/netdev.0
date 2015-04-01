From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [RFC PATCH v3 0/2] can: join filters with per-CPU variables
Date: Wed,  1 Apr 2015 07:50:27 +0200
Message-ID: <1427867429-3909-1-git-send-email-socketcan@hartkopp.net>
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	Oliver Hartkopp <socketcan@hartkopp.net>
To: linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

as Andre Naujoks found some problems in my first patches with multi-threading
I did some investigation how to handle variables to be written inside the
NET_RX softirq without locking. As far as I was able to test this code it works
properly now - even with the multi-thread test from Andre.

If you know how to use per-CPU variables inside NET_RX softirq I would
appreciate your review as I'm not that sure that the per-CPU code is correct.
It's my first time using this technique and is only what I was able to get from
other code examples and available kernel docs.

Many thanks,
Oliver

Changes v1 -> v2:
* Introduce per-CPU variables

Changes v2 -> v3:
* Fix style issues remarked by Sergei Shtylyov and Marc Kleine-Budde
* Indroduced a per-CPU struct as suggested by Marc Kleine-Budde
* omitted the obsolete per-CPU struct data initialization as alloc_percpu
  provides already zero'ed memory 


Oliver Hartkopp (2):
  can: fix multiple delivery of a single CAN frame for overlapping CAN
    filters
  can: introduce new raw socket option to join the given CAN filters

 Documentation/networking/can.txt | 20 ++++++++++++++--
 include/uapi/linux/can/raw.h     |  1 +
 net/can/raw.c                    | 50 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 69 insertions(+), 2 deletions(-)

-- 
2.1.4

