From: jamal <hadi@cyberus.ca>
Subject: RE: [PATCH] NET: Multiqueue network device support.
Date: Mon, 11 Jun 2007 18:22:16 -0400
Message-ID: <1181600536.4071.55.camel@localhost>
References: <D0122E209EBF8D4CAB38EC6A8AF244E502AB2937@hasmsx412.ger.corp.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: "Cohen, Guy" <guy.cohen@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.176]:8864 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752132AbXFKWWU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 18:22:20 -0400
Received: by py-out-1112.google.com with SMTP id a29so2907476pyi
        for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 15:22:19 -0700 (PDT)
In-Reply-To: <D0122E209EBF8D4CAB38EC6A8AF244E502AB2937@hasmsx412.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 2007-11-06 at 18:34 +0300, Cohen, Guy wrote:

> jamal wrote:
[..]
> > WMM is a strict prio mechanism.
> > The parametrization very much favors the high prio packets when the
> > tx opportunity to send shows up.
> 
> Sorry, but this not as simple as you describe it. WMM is much more
> complicated. WMM defines the HW queues as virtually multiple clients
> that compete on the medium access individually. Each implements a
> contention-based medium access. The Access Point publishes to the
> clients the medium access parameters (e.g. back off parameters) that are
> different for each access category (virtual client). There is _not_ a
> strict priority assigned to each access category. 

You sound like you know this stuff well so please bear with me. I am
actually hoping i will learn from you.

I dont have access to the IEEE docs but i have been reasonably following
up on the qos aspect and i have a good feel for how the parameters work.
I posted a url to a pdf earlier which describes the WMM default
parameterization for each AC you refer to above - do you wanna comment
on the accuracy of that?

> The behavior of each
> access category totally depends on the medium usage of other clients and
> is totally different for each access category. This cannot be predicated
> at the host SW.

It could be estimated well by the host sw; but lets defer that to later
in case i am clueless on something or you misunderstood something i
said.

> QoS in WLAN doesn't
> favor strictly one access category over another, but defines some softer
> and smarter prioritization. This is implemented in the HW/Firmware. 

I understand.  Please correct me if am wrong:
The only reason AC_BK packet will go out instead of AC_VO when
contending in hardware is because of a statistical opportunity not the
firmware intentionaly trying to allow AC_BK out 
i.e it is influenced by the three variables:
1) The contention window 2) the backoff timer and 3)the tx opportunity
And if you look at the default IEEE parameters as in that url slide 43,
the only time AC_BK will win is luck.

> I
> just think that providing a per-queue controls (start/stop) will allow
> WLAN drivers/Firmware/HW to do that while still using qdisc (and it will
> work properly even when one queue is full and others are empty).

I dont see it the same way. But iam willing to see wireless in a
different light than wireless, more below.

> > however, it is feasible that high prio
> > packets will obstruct low prio packets (which is fine).
> 
> No this is _not_ fine. Just to emphasize again, WMM doesn't define
> priority in the way it is implemented in airplane boarding (Pilots
> first, Business passengers next, couch passengers at the end), but more
> like _distributed_ weights prioritization (between all the multiple
> queues of all the clients on the channel).


I am not trying to be obtuse in any way - but let me ask this for
wireless contention resolution:
When a bussiness passenger is trying to get into plane at the same time
as a couch passenger and the attendant notices i.e to resolve the
contention, who gets preferential treatment? There is the case of the
attendant statistically not noticing (but that accounts for luck)...

Heres a really dated paper before the standard was ratified:
http://www.mwnl.snu.ac.kr/~schoi/publication/Conferences/02-EW.pdf

a) looking at table 1 at the AIFS, CWmin/max and PF used in the
experiment I dont see how a low prio or mid prio ac will
ever beat something in the high prio just by virtue that they have
longer AIFS + CW values. Maybe you can explain (trust me i am trying to
resolve this in my mind and not trying to be difficult in any way; i am
a geek and these sorts of things intrigue me; i may curse but thats ok)
The only way it would happen is if there is no collision i.e stastical
"luck".
b) The paragraph between fig 4 and fig 5 talks about "virtual collision"
between two TCs within a station as _always_ favoring the higher prio.

Slide 43 on:
http://madwifi.org/attachment/wiki/ChipsetFeatures/WMM/qos11e.pdf?format=raw
also seems to indicate the default parameters for the different timers
is clearly strictly in favor of you if you have higher prio.
Do those numbers cross-reference with the IEEE doc you may have?

> As a side note, in one of the WFA WMM certification tests, the AP
> changes the medium access parameters of the access categories in a way
> that favors a lower access category. This is something very soft that
> cannot be reflected in any intuitive way in the host SW.

So essentially the test you mention changes priorities in real time. 
What is the purpose of this test? Is WMM expected to change its
priorities in real time?

cheers,
jamal


