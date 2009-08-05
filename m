From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: bridge vs macvlan performance (was: some veth related issues)
Date: Wed, 05 Aug 2009 08:41:54 +0300
Message-ID: <4A791BA2.1040503@voltaire.com>
References: <Pine.LNX.4.64.0908041650560.13803@zuben.voltaire.com>	<4A785824.2030500@candelatech.com> <4A790D24.9000008@voltaire.com> <4A790F35.60204@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Vytautas Valancius <vytautas.valancius@gmail.com>,
	Sapan Bhatia <sapanb@cs.princeton.edu>,
	virtualization@lists.linux-foundation.org
To: Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:41858 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933150AbZHEFmD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2009 01:42:03 -0400
In-Reply-To: <4A790F35.60204@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> Well, it seems we could and should fix veth to work, but it will have 
> to do equivalent work of copying  an skb most likely, so either way 
> you'll probably get a big performance hit.
Using the same pktgen script (i.e with clone=0) I see that a 
veth-->bridge-->veth configuration gives about 400K PPS forwarding 
performance where macvlan-->veth-->macvlan gives 680K PPS (again, I made 
sure that the bridge has applied learning before I start the test). 
Basically, both the bridge and macvlan use hash on the destination mac 
in order to know to which device forward the packet, is there anything 
in the bridge logic that can explain the gap? It there something which 
isn't really apples-to-apples in this comparison?

Or.

