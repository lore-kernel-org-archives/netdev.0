From: Timo Teras <timo.teras@iki.fi>
Subject: Re: [PATCH v2 net-next] arp: flush arp cache on IFF_NOARP change
Date: Thu, 23 May 2013 10:49:44 +0300
Message-ID: <20130523104944.4b7ce6c2@vostro>
References: <20130520.134633.448574202175922639.davem@davemloft.net>
	<1369131824-6318-1-git-send-email-timo.teras@iki.fi>
	<20130523.000136.1188829048647539329.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:46390 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753897Ab3EWHsJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 03:48:09 -0400
Received: by mail-ee0-f48.google.com with SMTP id b47so1595923eek.7
        for <netdev@vger.kernel.org>; Thu, 23 May 2013 00:48:08 -0700 (PDT)
In-Reply-To: <20130523.000136.1188829048647539329.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 May 2013 00:01:36 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Timo Ter=E4s <timo.teras@iki.fi>
> Date: Tue, 21 May 2013 13:23:44 +0300
>=20
> > IFF_NOARP affects what kind of neighbor entries are created
> > (nud NOARP or nud INCOMPLETE). If the flag changes, flush the arp
> > cache to refresh all entries.
> >=20
> > Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>
>=20
> I agree with Ben that we should have a "orig_priv_flags" or
> something like that to implement this, rather than adding
> transient state flags to ->priv_flags.

Sure. I'll split this to two patches then and do this.

I would prefer "flags_changed" as then the notifiers can easily test on
the change. Usually the care only about the new state, or if it
changed. Otherwise the change calculation is needed on all notify
callbacks.

Will post this briefly, unless you feel that "orig_flags" is still
preferred.
