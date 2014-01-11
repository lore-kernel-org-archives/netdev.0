From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH net-next] IPv6: enable TCP to use an anycast address
Date: Sat, 11 Jan 2014 17:38:27 +0400
Message-ID: <CAMrnHh76D1d_JrXhtz+nvJP+Aiux2iPW+5uVZqQpbmWbQG0=OQ@mail.gmail.com>
References: <CAMrnHh6pBYMLn+zsR2P_oo8KufJq7Dkjm-cSq2N2Hi638yrUog@mail.gmail.com>
	<1389445570.24657.YahooMailBasic@web125502.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: =?ISO-8859-1?Q?Fran=E7ois=2DXavier_Le_Bail?= <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:44138 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011AbaAKNi2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jan 2014 08:38:28 -0500
Received: by mail-ie0-f172.google.com with SMTP id u16so5707757iet.31
        for <netdev@vger.kernel.org>; Sat, 11 Jan 2014 05:38:28 -0800 (PST)
In-Reply-To: <1389445570.24657.YahooMailBasic@web125502.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On Sat, Jan 11, 2014 at 5:06 PM, Fran=E7ois-Xavier Le Bail
<fx.lebail@yahoo.com> wrote:
> Many DNS root-servers use TCP with anycast (IPv4 and IPV6).
>
> see : http://tools.ietf.org/html/draft-jabley-dnsop-anycast-mapping-0=
4#section-4
>
> "   L-Root service is provided using a single IPv4 address (199.7.83.=
42)
>    and a single IPv6 address (2001:500:3::42).  It should be noted th=
at
>    it is preferable to refer to the service using its DNS name (L.ROO=
T-
>    SERVERS.NET) rather than literal addresses, since addresses can
>    change from time to time."

Is this all? It looks like this implies routing by deep packet inspecti=
on,
fetching some creepy node identification options from inside DNS payloa=
d
(not written directly, but  implied). This smells funky.

Actually, I was alerted by reset processing in your patch, it cannot be=
 right.

Do not you think this must not be enabled for common use? At least
some separate sysctl disabled by default.
