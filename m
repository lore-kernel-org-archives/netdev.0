From: Ulrich Weber <ulrich.weber@sophos.com>
Subject: Re: [PATCH 1/3] xfrm: add incoming interface to selector
Date: Wed, 30 Nov 2011 18:33:54 +0100
Message-ID: <4ED66902.7060507@sophos.com>
References: <1322511292-1413-1-git-send-email-ulrich.weber@sophos.com>	<1322511292-1413-2-git-send-email-ulrich.weber@sophos.com> <20111129.190037.1527680744377783412.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx5.sophos.com ([213.31.172.35]:39763 "EHLO mx5.sophos.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756705Ab1K3Rd5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Nov 2011 12:33:57 -0500
In-Reply-To: <20111129.190037.1527680744377783412.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30.11.2011 01:00, David Miller wrote:
>
> This isn't safe, because we have no idea if existing users are puttin=
g
> garbage there.  So your change can break things.
>
> You'll have to add a netlink attribute or similar.
But a implementation matching xfrm against UID would break
existing programs too, where sel->user is set to garbage.

I checked all common programs, they set sel->user to zero:

iproute 3.1.0: sel->user is shown if set, but its not possible to set i=
t
openswan 2.6.37: xfrm_selector memset to zero
strongswan 4.6.1: ifindex and user set to zero
ipsec-tools 0.8.0: PF_KEY only (memset to zero in net/key/af_key.c)
ike 2.1.7: PF_KEY only
isakmpd 20041012: PF_KEY only

Cheers
Ulrich

--=20
Ulrich Weber | ulrich.weber@sophos.com | Senior Software Engineer
Astaro - a Sophos company | Amalienbadstr 41 | 76227 Karlsruhe | German=
y
Phone +49-721-25516-0 | Fax =96200 | www.astaro.com
