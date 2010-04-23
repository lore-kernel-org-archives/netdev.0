From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] NIU support for skb->rxhash
Date: Fri, 23 Apr 2010 08:32:02 -0700
Message-ID: <h2z65634d661004230832o4f7a6d35ub207bc301ee8925c@mail.gmail.com>
References: <20100422.042157.99869295.davem@davemloft.net>
	 <1271936598.7895.5304.camel@edumazet-laptop>
	 <20100422.141922.39169749.davem@davemloft.net>
	 <20100423.011456.48472321.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:40123 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757383Ab0DWPcJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 11:32:09 -0400
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [10.3.21.12])
	by smtp-out.google.com with ESMTP id o3NFW6QZ031173
	for <netdev@vger.kernel.org>; Fri, 23 Apr 2010 17:32:06 +0200
Received: from pvb32 (pvb32.prod.google.com [10.241.209.96])
	by hpaq12.eem.corp.google.com with ESMTP id o3NFW25d024853
	for <netdev@vger.kernel.org>; Fri, 23 Apr 2010 17:32:05 +0200
Received: by pvb32 with SMTP id 32so58475pvb.4
        for <netdev@vger.kernel.org>; Fri, 23 Apr 2010 08:32:02 -0700 (PDT)
In-Reply-To: <20100423.011456.48472321.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I looked into implementing this and it doesn't work. =A0The
> problem is GRO want's to look into the packet very early
> and we want to batch GRO a set of packets into a big packet
> before shooting them over to a remote cpu.
>

Can you reconsider? :-)  The majority of our servers see packet loads
which don't allow for much batching (a lot of small RPC messages), so
for those GRO is mostly unnecessary overhead and mechanisms that
improve unbatched packet performance are compelling.  Also, if a
device already does LRO, I don't see that GRO could add a lot of value
anyway.

Tom

> This reminds me that we can start using ->rxhash as a quick
> mismatch check in the GRO flow matcher.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
