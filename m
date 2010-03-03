From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH 1/8] net: add limit for socket backlog
Date: Wed, 03 Mar 2010 16:59:51 +0800
Message-ID: <1267606791.2370.156.camel@debian>
References: <1267598111-12503-1-git-send-email-yi.zhu@intel.com>
	 <1267599269.2839.84.camel@edumazet-laptop>
	 <1267601728.2370.47.camel@debian>
	 <1267603357.2839.105.camel@edumazet-laptop>
	 <1267604053.2370.102.camel@debian>
	 <1267606075.2997.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Per Liden <per.liden@ericsson.com>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	Andrew Hendry <andrew.hendry@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:2128 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753328Ab0CCI6J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 03:58:09 -0500
In-Reply-To: <1267606075.2997.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-03-03 at 16:47 +0800, Eric Dumazet wrote:
> Le mercredi 03 mars 2010 =C3=A0 16:14 +0800, Zhu Yi a =C3=A9crit :
>=20
> > I want to provide a method for protocols to set its sock backlog li=
mit.
> > For example, the sctp_rmem is 373500 (sysctl_sctp_rmem[1]) which is
> > larger than (sysctl_rmem_default << 1). But I'm not very sure about=
 the
> > actual required size. So I didn't make it in the sctp patch. What d=
o you
> > think?
>=20
> I think this is not about bug fixes, but followup patches.
>=20
> We should first address the bug asap, then do further refinements lat=
er.

I'm trying not to break the already working protocols which assume the
backlog is unlimited. In your example, apparently define MINBACKLOG to
2048 is too small. Then what should it be? I'm waiting for responses
from individual protocol maintainers. If all of them feel
(sysctl_rmem_default << 1) is OK, I can remove the .limit and use it
instead.

Thanks,
-yi

