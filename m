From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Wed, 20 Apr 2016 22:13:50 +0200
Message-ID: <1461183230.2176.28.camel@sipsolutions.net>
References: <20160418.214851.122286645854721047.davem@davemloft.net>
	 <20160418.235207.395468709808133833.davem@davemloft.net>
	 <1461060543.2766.20.camel@sipsolutions.net>
	 <20160419.142324.1774057494079734967.davem@davemloft.net>
	 <1461094901.2766.26.camel@sipsolutions.net>
	 <5716E123.8040002@cumulusnetworks.com>
	 <1461137540.2176.5.camel@sipsolutions.net>
	 <20160420144828.5537dce7@griffin>
	 <1461158228.2176.18.camel@sipsolutions.net>
	 <20160420153449.5dd5fb24@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Ahern <dsa@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	roopa@cumulusnetworks.com, netdev@vger.kernel.org,
	jhs@mojatatu.com, tgraf@suug.ch, nicolas.dichtel@6wind.com,
	egrumbach@gmail.com
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:58720 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750902AbcDTUN7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2016 16:13:59 -0400
In-Reply-To: <20160420153449.5dd5fb24@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-04-20 at 15:34 +0200, Jiri Benc wrote:
> On Wed, 20 Apr 2016 15:17:08 +0200, Johannes Berg wrote:
> >=20
> > Looks like you have this on a per-message basis. I thought it was
> > better on an attribute basis because that's really where the issue
> > is.
> No problem. I'm not that happy with my patchset myself. Just wanted
> to point it out in case it's useful.

Yeah, I looked at it, but I think it ended up a bit too complicated
really.

It does have slightly more validation in some sense, but I don't really
think that justifies the complexity?

No matter what, we'll always have to deal with the problem of not
having this capability on older kernels. One way to work around it
would be to add a new=C2=A0NLM_F_REQUEST2 flag, since the kernel curren=
tly
requires having=C2=A0NLM_F_REQUEST set,=C2=A0NLM_F_REQUEST2 messages wo=
uld be
rejected by existing kernels. Dunno if it's really worth it though, I
suspect that family/command-specific detection will work in practically
all cases.

johannes
