From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net] ipv4: add support for "gratuitous" redirect
Date: Wed, 30 Sep 2015 14:55:18 +0200
Message-ID: <1443617718.6398.25.camel@dhcp-176-88.mxp.redhat.com>
References: <a3cf0539c78b2d8641539a8467daf840c259f310.1443186508.git.pabeni@redhat.com>
	 <20150929.114921.767637932140523708.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, corbet@lwn.net, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39410 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932144AbbI3MzY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 08:55:24 -0400
In-Reply-To: <20150929.114921.767637932140523708.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2015-09-29 at 11:49 -0700, David Miller wrote:
> I don't know if it's a question of terminology but RFC1122 does
> seem to ask us to make this check, from 3.2.2.2:
> 
>         A Redirect message SHOULD be silently discarded if ... the
>         source of the Redirect is not the current first-hop gateway
>         for the specified destination (see Section 3.3.1).

According to the same RFC:

*    "SHOULD"

              This word or the adjective "RECOMMENDED" means that there
              may exist valid reasons in particular circumstances to
              ignore this item, but the full implications should be
              understood and the case carefully weighed before choosing
              a different course. 

So, if we agree that there are valid reasons we can make this check
optional.

> Whereas if we changed the routers to send ICMP redirects that these
> hosts would actually accept, you'd only have to make the change on
> the routers.  This is several orders of magnitude easier to deploy.

Actually fixing this behavior on the VRRP router requires somewhat
'NATing' ICMP redirect packets, which AFAIK is not possible on a Linux
box, since ICMP reply packets do not traverse the nat table.

To cope with the original issue on the router, it would be needed an
'icmp_errors_use_inbound_daddr' sysctl, that, when enabled, forces the
kernel to send icmp error messages using the destination address of the
incoming packet as source. 

Eventually we can restrict the above option to icmp redirect only.

Do you think that adding such configuration would be more acceptable?

Some time ago, there was already some discussion on this topic:

http://comments.gmane.org/gmane.linux.kernel/1128505

Thank you,

Paolo
