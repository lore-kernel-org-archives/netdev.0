From: "Cohen, Guy" <guy.cohen@intel.com>
Subject: RE: [PATCH] NET: Multiqueue network device support.
Date: Tue, 12 Jun 2007 17:04:19 +0300
Message-ID: <D0122E209EBF8D4CAB38EC6A8AF244E502AB31CF@hasmsx412.ger.corp.intel.com>
References: <1181600536.4071.55.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Patrick McHardy" <kaber@trash.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:46714 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753301AbXFLOEd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 10:04:33 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1181600536.4071.55.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Jamal,

Here is a simple scenario (nothing here is rare of extreme case):
- Busy wireless environment
- FTP TX on BE queue (low priority)
- Skype TX on VO queue (high priority)

The channel is busy with high priority packets hence the BE packets are
transmitted to the air rarely so the DMA/HW queue of the BE access
category gets full and the qdisc is stopped.
Now periodic VO-tagged Skype packets arrive. I would expect that they
get the priority (and pass) in all stages of the stack and reach the HW
ASAP and compete there on the medium with the other access categories
and the other clients on the channel.
Now this packet will be stuck in the qdisc and wait there until a BE
packet is transmitted, which can take a long time. This is a real
problem.

There is also a problem with the queues that will be dedicated to TX
aggregation in 11n (currently implemented) - the packets will be
classified to queues by the destination MAC address and not only by the
priority class, but I don't want to get into that now. I think that
there are enough arguments now why the patch that started this thread is
needed...

Please see below some replies to your questions.

Regards,
Guy.


jamal wrote:
> It could be estimated well by the host sw; but lets defer that to
later
> in case i am clueless on something or you misunderstood something i
> said.

It cannot be estimated well by the host SW. This is one of the main
issues - we can't put it aside...

> I understand.  Please correct me if am wrong:
> The only reason AC_BK packet will go out instead of AC_VO when
> contending in hardware is because of a statistical opportunity not the
> firmware intentionaly trying to allow AC_BK out
> i.e it is influenced by the three variables:
> 1) The contention window 2) the backoff timer and 3)the tx opportunity
> And if you look at the default IEEE parameters as in that url slide
43,
> the only time AC_BK will win is luck.

In most scenarios BK packets will be transmitted and will win the medium
against VO packets (thought, in some non-favored ratio).

> Heres a really dated paper before the standard was ratified:
> http://www.mwnl.snu.ac.kr/~schoi/publication/Conferences/02-EW.pdf

Sorry, I'm really overloaded - I won't be able to review the docs you
sent (really apologize for that).

> So essentially the test you mention changes priorities in real time.
> What is the purpose of this test? Is WMM expected to change its
> priorities in real time?

The WMM parameters of the AC are set and controlled by the network/BSS
(access point) administrator and can be used in anyway. There are the
default parameters but they can be changed.

Regards,
Guy.
