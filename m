From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: Question: how to detect if a qdisc is root or not?
Date: Wed, 18 Jul 2007 16:29:19 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC3290340F87C@orsmsx414.amr.corp.intel.com>
References: <469EA106.5010106@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:44603 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936617AbXGRX3V convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 19:29:21 -0400
Content-class: urn:content-classes:message
In-Reply-To: <469EA106.5010106@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> You're right, thats a bug. TC_H_ROOT is the parent ID, which 
> is stored in sch->parent. IIRC its also passed to the 
> ->init() function.

Unfortunately it's not passed.  It is passed into the ->change()
function:

static int prio_init(struct Qdisc *sch, struct rtattr *opt)

static int prio_change(struct Qdisc *sch, u32 handle, u32 parent, struct
rtattr **tca, unsigned long *arg)

I did mess around with sch->parent a bit, with no success (it appears to
be zero / unitialized).  I'll keep investigating.

Thanks,

-PJ Waskiewicz
