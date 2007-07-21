From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: Linux, tcpdump and vlan
Date: Sat, 21 Jul 2007 23:15:43 +0200
Message-ID: <m3ps2l5ugw.fsf@maximus.localdomain>
References: <997818.30021.qm@web56615.mail.re3.yahoo.com>
	<m31wf226fw.fsf@maximus.localdomain>
	<46A11C54.2090100@candelatech.com>
	<m3sl7idmb4.fsf@maximus.localdomain>
	<46A248FA.1050403@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andrei radulescu-banu <iubica2@yahoo.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:49898 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755291AbXGUVPr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jul 2007 17:15:47 -0400
In-Reply-To: <46A248FA.1050403@candelatech.com> (Ben Greear's message of "Sat, 21 Jul 2007 10:57:14 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear <greearb@candelatech.com> writes:

>> IOW: I think all Ethernet interfaces should always be VLAN-aware,
>> stripping the tag (only one) early on RX and adding it late on TX.
>> That means tcpdump would see packets with exactly one tag removed
>> (unless there was no tag), in both RX and TX.
>>
>> Tcpdump would need other means to get VLAN id...
>>
> What benefit will this add?  It will certainly decrease performance to
> copy around
> the header for every VLAN packet, so there would have to be a good reason to
> add this logic...

I'd have to do some tests... Hopefully in this decade, forget it for
now.

The primary reason - consistency with hw VLAN cards -> simpler
code.

The performance is already decreased (not sure if it's noticeable)
most of the time, i.e., when not transparently bridging VLAN
trunks. Bridging VLAN trunks is, of course, theoretically possible,
but it's rather not a common operation when using .1Q.
That is, with header reordering, of course.

Anyway, -ENOPATCH from me for now.
-- 
Krzysztof Halasa
