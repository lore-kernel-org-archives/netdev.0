From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [RFC] ipv6: use a random ifid for headerless devices
Date: Thu, 03 Dec 2015 20:29:53 +0100
Message-ID: <87vb8fjpou.fsf@nemi.mork.no>
References: <1448884508-5235-1-git-send-email-bjorn@mork.no>
	<1448968942.3320842.454553905.2C5FBADD@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:35298 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753163AbbLCTaA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 14:30:00 -0500
In-Reply-To: <1448968942.3320842.454553905.2C5FBADD@webmail.messagingengine.com>
	(Hannes Frederic Sowa's message of "Tue, 01 Dec 2015 12:22:22 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa <hannes@stressinduktion.org> writes:

> I see no problem with the patch as it eases operating those devices. =
I
> would also suggest storing the ifid in the inet6_dev so it does only
> change during device creation and destruction. Otherwise I would
> recommend to use stable privacy addresses to generate the link local
> addresses. EUI-48 based LL creation should hopefully not be used anym=
ore
> soon.

Thanks for commenting on this. Yes, the stable privacy addresses looks
like they will solve this and other problems.  But enabling them requir=
e
an adminstrator action.

After looking more at addrconf, I started wondering if we couldn't abus=
e
ipv6_generate_stable_address() for this purpose?  We could add a new
addr_gen_mode which would trigger automatic generation of a secret if
stable_secret is uninitialized.  This would be good enough to ensure
stability until the interface is destroyed.  And it would still allow
the adminstrator to select IN6_ADDR_GEN_MODE_STABLE_PRIVACY by entering
a new secret.


Bj=C3=B8rn
