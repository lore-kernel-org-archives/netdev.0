From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2 net-next 2/2] tc: make ingress and egress qdiscs
 consistent
Date: Wed, 8 Apr 2015 14:14:17 +0100
Message-ID: <20150408131417.GA28656@casper.infradead.org>
References: <20150407.223549.335906307265617841.davem@davemloft.net>
 <55249EFA.5040405@plumgrid.com>
 <5524B339.1070403@plumgrid.com>
 <5524E878.7070803@iogearbox.net>
 <20150408090520.GA2057@nanopsycho.orion>
 <552508E8.5050203@iogearbox.net>
 <55250D92.6030702@iogearbox.net>
 <55251556.4040900@mojatatu.com>
 <55251F9F.2050508@iogearbox.net>
 <55252611.3040109@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:47022 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753396AbbDHNOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 09:14:19 -0400
Content-Disposition: inline
In-Reply-To: <55252611.3040109@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/15 at 08:58am, Jamal Hadi Salim wrote:
> On 04/08/15 08:31, Daniel Borkmann wrote:
> >That means the tc's cls_u32
> >sample selectors a la ip, ip6, udp, tcp, icmp don't work on ingress
> >either,so in u32 speak you would need to do that by hand, but that
> >doesn't work as you don't have the Ethernet type context available.
> >Am I missing something? :)
> 
> u32 works fine. I am sure i have tests which run these on both
> in/egress.

His point is that an u32 filter written for egress won't work at
ingress because the offsets are different. This has always been the
case and we can't break this behaviour either. I'm sure you have
these weird negative offset u32 egress filters in your repertoire
as well ;-)

Even if we made ingress offsets start at the network header we
would still have to make this depend on a flag which new users have
to set.
