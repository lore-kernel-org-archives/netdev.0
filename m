From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC flow-net-next 00/10] Flow Table API Cache Enhancements
Date: Mon, 29 Dec 2014 11:15:30 +0900
Message-ID: <1419819340-19000-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: John Fastabend <john.r.fastabend@intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:33679 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751607AbaL2CPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2014 21:15:53 -0500
Received: by mail-pd0-f181.google.com with SMTP id v10so16226832pde.12
        for <netdev@vger.kernel.org>; Sun, 28 Dec 2014 18:15:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John, Hi All,

the purpose of this patch-set is to propose enhancements to the flow table
API which you have been working on.  The enhancements focus on optional
support for tables which act as caches, where a cache is defined to be a
table that may remove entries other than via an explicit remove-flow API
call.

I will be up-front and say that many of the ideas implemented here have
been inspired by OpenFlow: something that I am familiar with.

A possible user of flow timeouts and counters, is Open vSwitch: it does not
currently make use of the Flow Table API but it treats its datapath as a
typically manages the cached by removing flows based on statistics
indicating the idleness of flows.

That said, I am not attempting to make the Flow Table API OpenFlow or Open
vSwitch specific. I have attempted to make all the enhancements optional,
so that they may only be used in software and hardware scenarios where they
make sense.

Thus far I have only prototyped the netlink API side of these enhancements
and compile tested them.

This series is based on John Fastabend's flow-net-next tree
https://github.com/jrfastab/flow-net-next


Simon Horman (10):
  net: flow: Correct spelling of action
  net: flow: Add features to tables
  net: flow: Add timeouts to flows
  net: flow: Add counters to flows
  net: flow: Add get, set and del notifier commands
  net: flow: Add flow removed notification
  net: flow: Add importance to flows
  net: flow: Add get and set table config commands
  net: flow: Add eviction flags to table configuration
  net: flow: Add flow removed notification for eviction

 include/linux/if_flow.h      |   3 +
 include/linux/netdevice.h    |  10 +
 include/uapi/linux/if_flow.h | 232 +++++++++++++++++-
 net/core/flow_table.c        | 561 ++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 798 insertions(+), 8 deletions(-)

-- 
2.1.3
