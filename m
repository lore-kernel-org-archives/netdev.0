From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] ipv4: synchronize bind() with RTM_NEWADDR notifications
Date: Thu, 21 Oct 2010 14:57:51 +0300
Message-ID: <4CC02ABF.8090008@iki.fi>
References: <4CC01CC0.7090101@iki.fi>	<20101021.040319.191412436.davem@davemloft.net>	<4CC02412.8050000@iki.fi> <20101021.043421.108778257.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:58588 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753368Ab0JUL5x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 07:57:53 -0400
Received: by ewy20 with SMTP id 20so5636904ewy.19
        for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 04:57:52 -0700 (PDT)
In-Reply-To: <20101021.043421.108778257.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/21/2010 02:34 PM, David Miller wrote:
> From: Timo Ter=E4s <timo.teras@iki.fi>
> Date: Thu, 21 Oct 2010 14:29:22 +0300
>=20
>> This is the third time asking, what would be a good way to fix the
>> problem described in the original commit log?
>=20
> I kept your report in my inbox backlog and intended to think about
> it as time permitted.
>=20
> As the merge window has just openned up, for me time will not be
> "permitted" for some time.

=46air enough. Just getting multiple "does not work" without single
mention of "will think about this later" felt frustrating.

I have one more alternative: Would it be acceptable if we did
rtnl_lock()/rtnl_unlock() only if inet_addr_type() earlier said the
address is unacceptable for binding. And then retry inet_addr_type(). O=
r
do you think that the error case EADDRNOTAVAIL is a hot path too?
