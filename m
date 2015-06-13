From: sfeldma@gmail.com
Subject: [PATCH net-next 0/5] rocker: revert back to support for nowait processes
Date: Fri, 12 Jun 2015 21:35:45 -0700
Message-ID: <1434170150-63838-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, simon.horman@netronome.com,
	makita.toshiaki@lab.ntt.co.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:33069 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbbFMEeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2015 00:34:00 -0400
Received: by igbpi8 with SMTP id pi8so23455573igb.0
        for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 21:33:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

One of the items removed from the rocker driver in the Spring Cleanup patch
series was the ability to mark processing in the driver as "no wait" for
those contexts where we cannot sleep.  Turns out, we have "no wait"
contexts where we want to program the device and we don't want to defer the
processing to a process context.  So re-add the ROCKER_OP_FLAG_NOWAIT flag
to mark such processes, and propagate flags to mem allocator and to the
device cmd executor.  With NOWAIT, mem allocs are GFP_ATOMIC and device
cmds are queued to the device, but the driver will not wait (sleep) for the
response back from the device.

My bad for removing NOWAIT support in the first place; I thought we could
swing non-sleep contexts to process context using a work queue, for
example, but there is push-back to keep processing in original context.


Scott Feldman (5):
  rocker: revert back to support for nowait processes
  rocker: mark neigh update event processing as 'no wait'
  rocker: mark STP update as 'no wait' processing
  rocker: move MAC learn event back to 'no wait' processing
  rocker: move port stop to 'no wait' processing

 drivers/net/ethernet/rocker/rocker.c |  245 ++++++++++++++++------------------
 1 file changed, 118 insertions(+), 127 deletions(-)

-- 
1.7.10.4
