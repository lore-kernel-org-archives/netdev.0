From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2017-10-19
Date: Thu, 19 Oct 2017 13:19:34 +0200
Message-ID: <20171019111945.13580-1-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:45313 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751436AbdJSLTv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 07:19:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is a pull request of 11 patches for the upcoming 4.14 release.

There are 6 patches by ZHU Yi for the flexcan driver, that work around
the CAN error handling state transition problems found in various
incarnations of the flexcan IP core.

The patch by Colin Ian King fixes a potential NULL pointer deref in the
CAN broad cast manager (bcm). One patch by me replaces a direct deref of a RCU
protected pointer by rcu_access_pointer. My second patch adds missing
OOM error handling in af_can. A patch by Stefan Mätje for the esd_usb2
driver fixes the dlc in received RTR frames. And the last patch is by
Wolfgang Grandegger, it fixes a busy loop in the gs_usb driver in case
it runs out of TX contexts.

regards,
Marc

---

The following changes since commit 28e33f9d78eefe98ea86673ab31e988b37a9a738:

  bpf: disallow arithmetic operations on context pointer (2017-10-18 13:21:13 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git tags/linux-can-fixes-for-4.14-20171019

for you to fetch changes up to 97819f943063b622eca44d3644067c190dc75039:

  can: gs_usb: fix busy loop if no more TX context is available (2017-10-19 13:05:54 +0200)

----------------------------------------------------------------
linux-can-fixes-for-4.14-20171019

----------------------------------------------------------------
Colin Ian King (1):
      can: bcm: check for null sk before deferencing it via the call to sock_net

Marc Kleine-Budde (2):
      can: af_can: do not access proto_tab directly use rcu_access_pointer instead
      can: af_can: can_pernet_init(): add missing error handling for kzalloc returning NULL

Stefan Mätje (1):
      can: esd_usb2: Fix can_dlc value for received RTR, frames

Wolfgang Grandegger (1):
      can: gs_usb: fix busy loop if no more TX context is available

ZHU Yi (ST-FIR/ENG1-Zhu) (6):
      can: flexcan: fix state transition regression
      can: flexcan: rename legacy error state quirk
      can: flexcan: implement error passive state quirk
      can: flexcan: fix i.MX6 state transition issue
      can: flexcan: fix i.MX28 state transition issue
      can: flexcan: fix p1010 state transition issue

 drivers/net/can/flexcan.c      | 91 +++++++++++++++++++++++++++++++++++-------
 drivers/net/can/usb/esd_usb2.c |  2 +-
 drivers/net/can/usb/gs_usb.c   | 10 +----
 net/can/af_can.c               | 20 ++++++++--
 net/can/bcm.c                  |  5 ++-
 5 files changed, 98 insertions(+), 30 deletions(-)
