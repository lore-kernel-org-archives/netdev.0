From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] net: allow CAP_NET_RAW to setsockopt SO_PRIORITY
Date: Mon, 24 Oct 2011 22:07:20 -0700
Message-ID: <CANP3RGfdimCqGL=kdVQdYY0KHqVuVL3CL6arRh3EhdNhyrv9cw@mail.gmail.com>
References: <1319518038-28679-1-git-send-email-zenczykowski@gmail.com>
	<20111025.005819.456617923859129015.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:44536 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752746Ab1JYFHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2011 01:07:23 -0400
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p9P57LlW027837
	for <netdev@vger.kernel.org>; Mon, 24 Oct 2011 22:07:21 -0700
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by hpaq1.eem.corp.google.com with ESMTP id p9P56AjA006655
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 24 Oct 2011 22:07:20 -0700
Received: by pzk36 with SMTP id 36so578641pzk.7
        for <netdev@vger.kernel.org>; Mon, 24 Oct 2011 22:07:20 -0700 (PDT)
In-Reply-To: <20111025.005819.456617923859129015.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> SO_PRIORITY influences the packet scheduler and internal
> queueing policies, not just the packet contents that hit
> the wire.
>
> Thus CAP_NET_ADMIN is the appropriate capability check.

I can certainly see why you would think that, but:

A raw socket can already spew traffic, ie. packets, with any content.
This includes VLAN tags and IPv4 TOS field, and IPv6 TCLASS field.
These are the fields used for packet prioritization at switches and in
the rest of network fabric.

AFAICT, it makes no sense to allow a raw socket to prioritize traffic
outside of the host, but
not allow it to prioritize traffic in the host.

- Maciej
