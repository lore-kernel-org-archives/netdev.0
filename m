From: "Cohen, Guy" <guy.cohen@intel.com>
Subject: RE: [PATCH] NET: Multiqueue network device support.
Date: Mon, 11 Jun 2007 17:30:07 +0300
Message-ID: <D0122E209EBF8D4CAB38EC6A8AF244E502AB28BA@hasmsx412.ger.corp.intel.com>
References: <466D5623.7060708@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: "Patrick McHardy" <kaber@trash.net>, <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:60420 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751471AbXFKOaQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 10:30:16 -0400
Content-class: urn:content-classes:message
In-Reply-To: <466D5623.7060708@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Patrick McHardy wrote:
> jamal wrote:
> > Sure - but what is wrong with that?
> 
> 
> Nothing, this was just to illustrate why I disagree with the
assumption
> that the packet has hit the wire. On second thought I do agree with
your
> assumption for the single HW queue case, at the point we hand the
packet
> to the HW the packet order is determined and is unchangeable. But this
> is not the case if the hardware includes its own scheduler. The qdisc
> is simply not fully in charge anymore.

For WiFi devices the HW often implements the scheduling, especially when
QoS (WMM/11e/11n) is implemented. There are few traffic queues defined
by the specs and the selection of the next queue to transmit a packet
from, is determined in real time, just when there is a tx opportunity.
This cannot be predicted in advance since it depends on the medium usage
of other stations.

Hence, to make it possible for wireless devices to use the qdisc
mechanism properly, the HW queues should _ALL_ be non-empty at all
times, whenever data is available in the upper layers. Or in other
words, the upper layers should not block a specific queue because of the
usage of any other queue.

> 
> Your basic assumption seems to be that the qdisc is still in charge
> of when packets get sent. This isn't the case if there is another
> scheduler after the qdisc and there is contention in the second
> queue.

Which is often the case in wireless devices - transmission scheduling is
done in HW.
