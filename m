From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: Linux, tcpdump and vlan
Date: Fri, 20 Jul 2007 21:58:27 +0200
Message-ID: <m31wf226fw.fsf@maximus.localdomain>
References: <997818.30021.qm@web56615.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: andrei radulescu-banu <iubica2@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:55067 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751689AbXGTT63 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2007 15:58:29 -0400
In-Reply-To: <997818.30021.qm@web56615.mail.re3.yahoo.com> (andrei radulescu-banu's message of "Thu, 19 Jul 2007 09:02:38 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Another idea - perhaps we could make the software VLANs behave
the same as hw ones? I.e., stripping the tag on RX while setting
some magic skb field?

The packets could go via main interface first (normal path, with
eth_type_trans stripping the tag and setting protocol = some 802.1Q),
netif_rx | netif_receive_skb, then through the VLAN device with
finally eth_type_trans setting the IPv4 etc. protocol to pass to
L3 layers.

I can see potential problems on TX, the packets would have to be
presented without the tag (but with VLAN ID set somewhere in the skb)
and that probably means all drivers would have to be modified.

Seems a bit of work, I know my message is missing the patch...
-- 
Krzysztof Halasa
