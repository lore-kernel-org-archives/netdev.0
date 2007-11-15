From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-2.6.25 1/4] include - Convert IP4 address class
	macros	to inline functions
Date: Wed, 14 Nov 2007 17:54:05 -0800
Message-ID: <1195091645.27053.1.camel@localhost>
References: <OF456A1240.FCBC428E-ON88257393.005C5D94-88257393.005CA64F@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@coreworks.de>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	netdev <netdev@vger.kernel.org>, netdev-owner@vger.kernel.org,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: David Stevens <dlstevens@us.ibm.com>,
	"Fred L. Templin" <fred.l.templin@boeing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1995 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751322AbXKOB41 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 20:56:27 -0500
In-Reply-To: <OF456A1240.FCBC428E-ON88257393.005C5D94-88257393.005CA64F@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-11-14 at 08:53 -0800, David Stevens wrote: 
> Maybe I'm more used to hex, but I personally don't think those are
> more readable. It replaces 1-line macroes with 4-line functions, and
> I think more vgrepping to pick out the relevant constant data.

The rfcs generally use decimal octets. 
To me htonl(0xC0586300) isn't as readable as ip4_addr_octets(192,88,99,0)

Fred Templin has some patches that add several more macros
to in.h.  I just forwarded my patches to him too.

is_ip4_multicast seems a lot more readable to me than MULTICAST(x)
I prefer to eliminate the current use of macros for ip address tests
and also get no new macros added.  The old macros are just for
compatibility until the exis

http://marc.info/?l=linux-netdev&m=119490504022261&w=2

His patch adds:

+#define PRIVATE_10(x) (((x) & htonl(0xff000000)) == htonl(0x0A000000)) 
+#define LINKLOCAL_169(x) (((x) & htonl(0xffff0000)) == htonl(0xA9FE0000))
+#define PRIVATE_172(x)	(((x) & htonl(0xfff00000)) == htonl(0xAC100000))
+#define TEST_192(x)	(((x) & htonl(0xffffff00)) == htonl(0xC0000200))
+#define ANYCAST_6TO4(x)	(((x) & htonl(0xffffff00)) == htonl(0xC0586300))
+#define PRIVATE_192(x)	(((x) & htonl(0xffff0000)) == htonl(0xC0A80000))
+#define TEST_198(x)	(((x) & htonl(0xfffe0000)) == htonl(0xC6120000))

cheers, Joe

