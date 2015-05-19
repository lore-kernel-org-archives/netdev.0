From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next 0/4] rocker: transaction fixes
Date: Tue, 19 May 2015 15:24:13 +0900
Message-ID: <1432016657-24231-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33535 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753108AbbESGYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 02:24:30 -0400
Received: by padbw4 with SMTP id bw4so9938794pad.0
        for <netdev@vger.kernel.org>; Mon, 18 May 2015 23:24:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this series addresses what appear to be errors in the handling of
prepare and then commit transactions in the rocker driver.

In all cases the problem is that data structures visible outside of
the transaction are modified during the prepare phase.

In the case of the first two patches this results in the kernel reporting a
BUG. I have noted test-cases in the change logs.

The remaining two patches do not fix bugs that manifest as far as
I can tell. Rather, they are correctness fixes.

Simon Horman (4):
  rocker: do not delete fdb entries in rocker_port_fdb_flush() when
    preparing transactions
  rocker: do not modify fdb table in rocker_port_fdb() when preparing
    transactions
  rocker: do not make neighbour entry changes when preparing
    transactions
  rocker: make rocker_port_internal_vlan_id_{get,put}()
    non-transactional

 drivers/net/ethernet/rocker/rocker.c | 46 ++++++++++++++++++++----------------
 1 file changed, 25 insertions(+), 21 deletions(-)

-- 
2.1.4
