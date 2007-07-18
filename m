From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Question: how to detect if a qdisc is root or not?
Date: Wed, 18 Jul 2007 16:16:32 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC3290340F84A@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Patrick McHardy" <kaber@trash.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:29538 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754223AbXGRXQe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 19:16:34 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've been tracking down an issue with the recent multiqueue code,
specifically with sch_prio and sch_rr loading as a root qdisc.  Right
now, we do not want to allow child qdiscs of sch_rr and sch_prio to load
with multiqueue enabled; we want to restrict multiqueue-enabled qdiscs
to the root qdisc (since this is the only thing to push into the
device).  The issue I have is I don't know how to detect if the qdisc
I'm currently processing is the root qdisc, or if it's a child.  From
sch_prio.c:

        q->mq = RTA_GET_FLAG(tb[TCA_PRIO_MQ - 1]);
        if (q->mq) {
                if (sch->handle != TC_H_ROOT)
                        return -EINVAL;

                if (netif_is_multiqueue(sch->dev)) { 

Unfortunately, this code isn't working.  This sch->handle is the handle
assigned to the qdisc upon creation, and it's not TC_H_ROOT.  Now the
information whether or not the qdisc is root gets passed via tc from
userspace, but that lives in the tcmsg struct, not the rtattr list of
options.  Does anyone know, outside of adding another attribute to the
rtattr list, how to detect if a qdisc is a root qdisc within the
prio_tune() initialization routine?  Any and all help would be much
appreciated.

Thanks,
 
PJ Waskiewicz
Intel Corporation
peter.p.waskiewicz.jr@intel.com <mailto:peter.p.waskiewicz.jr@intel.com>
