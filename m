From: "Fischer, Anna" <anna.fischer@hp.com>
Subject: RE: [RFC] bridge: prevent hairpin and STP problems?
Date: Mon, 17 Aug 2009 21:16:04 +0000
Message-ID: <0199E0D51A61344794750DC57738F58E6D6B0C79D7@GVW1118EXC.americas.hpqcorp.net>
References: <0199E0D51A61344794750DC57738F58E6D6B0C70D9@GVW1118EXC.americas.hpqcorp.net>
	<20090813.162716.207478915.davem@davemloft.net>
 <20090814144133.34ac9d94@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ptcongdon@ucdavis.edu" <ptcongdon@ucdavis.edu>,
	"evb@yahoogroups.com" <evb@yahoogroups.com>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"Dickson, Mike (ISS Software)" <mike.dickson@hp.com>,
	"adobriyan@gmail.com" <adobriyan@gmail.com>,
	"bridge@osdl.org" <bridge@osdl.org>, Arnd Bergmann <arnd@arndb.de>
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:15284 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758035AbZHQVQr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 17:16:47 -0400
In-Reply-To: <20090814144133.34ac9d94@nehalam>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Subject: [RFC] bridge: prevent hairpin and STP problems?
> 
> Do we need to add this to block Spanning Tree from being enabled
> with hairpin mode? I am not sure what the exact usage of hairpin
> mode and if it is possible to create loops and get STP confusion.
> 
> For comment only, do not apply as is.

Your patch disables STP on the whole bridge if one or more ports
are set to hairpin mode.

However, I don't really see that this is necessary. 

A hairpin mode port should not reflect BPDUs, because otherwise the
connected port would think it has detected a loop. The hairpin mode
port should still be able to generate BPDUs though, and in any case
the bridge should still be able to run STP.

The hairpin patch we submitted reflects packets on the forwarding /
data path whereas BPDUs are processed with a separate hook, so we
should not be reflecting BPDUs back out of a hairpin mode port.

Anna

