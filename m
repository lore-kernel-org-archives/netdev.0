From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/13] rocker: do world split
Date: Tue, 16 Feb 2016 13:55:25 +0100
Message-ID: <1455627338-9872-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com, tgraf@suug.ch, David.Laight@ACULAB.COM,
	john.fastabend@gmail.com, alexei.starovoitov@gmail.com,
	daniel@iogearbox.net, prem@barefootnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35925 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755189AbcBPMzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 07:55:41 -0500
Received: by mail-wm0-f47.google.com with SMTP id g62so105693172wme.1
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 04:55:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patchset allows new rocker worlds to be easily added in future.
Two new worlds are now under development: P4 and eBPF.

The main part of the patchset is the OF-DPA carve-out. It resuts in OF-DPA
specific file. Clean cut.

Note this patchset is based on my original attempt in October 2015.
I had to rebase, included all suggestions and did lot of small changes.
Main change to go with all-port-one-world approach. Port world is set according
to what is setup in HW. Not possible to change worlds from driver.

Jiri Pirko (13):
  rocker: remove unused rocker_port param from alloc funcs and shorten
    their names
  rocker: rename rocker.h to rocker_hw.h
  rocker: rename rocker.c to rocker_main.c
  rocker: push tlv processing into separate files
  rocker: implement get settings mode command
  rocker: move rocker and rocker_port structs into header
  rocker: introduce worlds infrastructure
  rocker: pass "learning" value as a parameter to
    rocker_port_set_learning
  rocker: pre-allocate wait structures during cmd ring init
  rocker: remove trans parameter to rocker_cmd_exec function
  rocker: call rocker_cmd_exec function with "nowait" boolean instead of
    flags
  rocker: move OF-DPA stuff into separate file
  rocker: return -EOPNOTSUPP for undefined world ops

 drivers/net/ethernet/rocker/Makefile       |    1 +
 drivers/net/ethernet/rocker/rocker.c       | 5495 ----------------------------
 drivers/net/ethernet/rocker/rocker.h       |  583 +--
 drivers/net/ethernet/rocker/rocker_hw.h    |  467 +++
 drivers/net/ethernet/rocker/rocker_main.c  | 2910 +++++++++++++++
 drivers/net/ethernet/rocker/rocker_ofdpa.c | 2947 +++++++++++++++
 drivers/net/ethernet/rocker/rocker_tlv.c   |   53 +
 drivers/net/ethernet/rocker/rocker_tlv.h   |  201 +
 8 files changed, 6711 insertions(+), 5946 deletions(-)
 delete mode 100644 drivers/net/ethernet/rocker/rocker.c
 create mode 100644 drivers/net/ethernet/rocker/rocker_hw.h
 create mode 100644 drivers/net/ethernet/rocker/rocker_main.c
 create mode 100644 drivers/net/ethernet/rocker/rocker_ofdpa.c
 create mode 100644 drivers/net/ethernet/rocker/rocker_tlv.c
 create mode 100644 drivers/net/ethernet/rocker/rocker_tlv.h

-- 
1.9.3
