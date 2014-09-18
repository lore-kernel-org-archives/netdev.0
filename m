From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC 0/8] Open vSwtich ODP Select Group Action
Date: Thu, 18 Sep 2014 10:52:25 +0900
Message-ID: <1411005153-11041-1-git-send-email-simon.horman@netronome.com>
Cc: Pravin Shelar <pshelar@nicira.com>, Jesse Gross <jesse@nicira.com>,
	Thomas Graf <tgraf@suug.ch>,
	Simon Horman <simon.horman@netronome.com>
To: dev@openvswtich.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:36561 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757004AbaIRBwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 21:52:44 -0400
Received: by mail-pd0-f178.google.com with SMTP id p10so308535pdj.37
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 18:52:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

the purpose of this patch-set is to provide a prototype of a select group
action in the Open vSwitch datapath. And the motivation for that is to
allow offloading of selection either in the datapath or by any hooks
provided by the datapath for hardware offloads (a topic of quite some
discussion elsewhere).

This proposal is also designed to tie in with another proposal we have
made to allow the selection method of a select group to be configured using
Open Flow. As such the selection method included in this patchset is
not the focus of this work: any method may be implemented. Rather,
the focus is on the ability to do selection in the datapath.

There are several implementation limitations of this prototype:

* It does not address per-bucket statistics.
  - We believe that the datapath can track per-bucket statistics and;
  - Expose them to user-space using new netlink attributes
* It assumes the select group comes last as the resulting packet
  may vary depending on the bucket that is chosen. Some possibilities
  for handling this include:
  - Performing selection in userspace for such cases
  - Using recirculation
* It seems that if recirculation may occur in more than one bucket
  then separate recirculation ids would be required. This prototype
  does not implement that.

This series is based on the Open vSwitch and its datapath maintained at
https://github.com/openvswitch/ovs.git

It is based on commit 5545e7826896e861c ("lib/odp-util: Add tunnel tp_src,
tp_dst parsing and formatting") of that tree.

Simon Horman (8):
  odp: select group action attributes
  netlink: Allow suppression of warnings for duplicate attributes
  odp-util: formatting of datapath select group action
  datapath: execution of select group action
  datapath: Move last_action() helper to datapath.h
  datapath: validation of select group action
  ofproto: translate datapath select group action
  hack: ofproto: enable odp select action

 datapath/actions.c                                |  74 ++++++++++++++-
 datapath/datapath.h                               |   5 +
 datapath/flow_netlink.c                           | 102 ++++++++++++++++++++
 datapath/linux/compat/include/linux/openvswitch.h |  31 +++++++
 lib/dpif-netdev.c                                 |   1 +
 lib/dpif.c                                        |   1 +
 lib/netlink.c                                     |   2 +-
 lib/netlink.h                                     |   1 +
 lib/odp-execute.c                                 |   1 +
 lib/odp-util.c                                    |  69 ++++++++++++++
 ofproto/ofproto-dpif-xlate.c                      | 108 +++++++++++++++++++++-
 11 files changed, 388 insertions(+), 7 deletions(-)

-- 
2.0.1
