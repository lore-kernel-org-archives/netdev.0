From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: Question about 802.3ad bonding mode.
Date: Mon, 28 Jul 2014 10:32:47 -0700
Message-ID: <22242.1406568767@localhost.localdomain>
References: <CAJN_NGY-u+rB1eBHV8XgdXPzwd2tQSmAf_=ZWFu2yob48siXzw@mail.gmail.com>
Cc: netdev@vger.kernel.org, willy@meta-x.org, const-g@xpert.com,
	girouard@us.ibm.com, ctindel@ieee.org, mitch.a.williams@intel.com
To: Dmitry Krivenok <krivenok.dmitry@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:53339 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167AbaG1Rc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 13:32:58 -0400
In-reply-to: <CAJN_NGY-u+rB1eBHV8XgdXPzwd2tQSmAf_=ZWFu2yob48siXzw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dmitry Krivenok <krivenok.dmitry@gmail.com> wrote:

>Hello,
>I have two physical NICs bonded into bond0 interface with bonding
>mode=4 (i,e, 802.3ad).
>Both NICs are connected to the same switch and switch ports are *not*
>configured in "lacp" mode.
[...]
>I have IP address configured on bond0 and from what I see it's fully
>working. I can ping it from various hosts, I can ssh to that host,
>etc. From user perspective it works just fine except that there is no
>LAG...
>
>Is that correct behavior of dynamic link aggregation via LACP?
>Shouldn't it be configuration error? Is it 802.1ax compliant?

	Your system is behaving correctly; there is a backwards
compatibility mechanism in the standard.

	Essentially, if there is no LACPDU exchange, the affected links
are marked as "Individual" (as opposed to "Aggregatable"), which means
that those links become members of an aggregator with exactly one
member: that link.

	Then, when the active aggregator to use for traffic is selected,
if all links are Individual, then one of those is selected, and there is
then one link that works for communication with the partner system.

	This is done intentionally to permit communication from a system
configured for LACP to a system that is not so configured.

	This is mentioned at a high level in IEEE 802.1AX section 5.1.2
(j), the Individual vs Aggregatable is in 5.3.5 and 5.3.6, the treatment
of Individual links is in 5.3.9, and 5.4.12 says, in part:

	If no LACPDU is received before the current_while timer expires
	again, the state machine transits to the DEFAULTED state. [...]
	This allows configuration of aggregations and individual links
	when no protocol Partner is present, while still permitting an
	active Partner to override default settings.  [...]

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
