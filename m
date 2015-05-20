From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH v2 net-next 0/4] rocker: transaction fixes
Date: Wed, 20 May 2015 11:00:08 +0900
Message-ID: <1432087212-29612-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Scott Feldman <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33876 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126AbbETCAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 22:00:23 -0400
Received: by pabru16 with SMTP id ru16so47936826pab.1
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 19:00:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this series addresses what appear to be errors in the handling of
prepare and then commit transactions in the rocker driver.

In all cases the problem is that data structures visible outside of
the transaction are modified during the prepare phase.

In the case of the first two patches this results in the kernel reporting a
BUG. I have noted test-cases in the change logs.

The third patch is also a bug fix, as noted by  Toshiaki Makita,
however I have not been able to reliably reproduce the problem and
thus have not provided a test case.

The last patch is a correctness fix that does not fix a bug
that manifests as far as I can tell.

Changes: v1->v2
* Added Ack's from Scott
* Revised changelog of third patch to reflect information from Toshiaki Makita:
  it seems there is a bug that can manifest
* Updated third patch to update address and ttl regardless of the
  value of the transaction state


Simon Horman (4):
  rocker: do not delete fdb entries in rocker_port_fdb_flush() when
    preparing transactions
  rocker: do not modify fdb table in rocker_port_fdb() when preparing
    transactions
  rocker: do not make neighbour entry changes when preparing
    transactions
  rocker: make rocker_port_internal_vlan_id_{get,put}()
    non-transactional

 drivers/net/ethernet/rocker/rocker.c | 46 +++++++++++++++++++-----------------
 1 file changed, 24 insertions(+), 22 deletions(-)

-- 
2.1.4
