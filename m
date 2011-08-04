From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH] bonding: document two undocumented options.
Date: Thu, 04 Aug 2011 07:41:53 +0200
Message-ID: <4E3A3121.3030403@gmail.com>
References: <1312315615-5739-1-git-send-email-nicolas.2p.debian@free.fr> <20110803.034425.1421983987148421662.davem@davemloft.net> <4E39A907.5040408@gmail.com> <3571.1312405193@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>, andy@greyhouse.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64300 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773Ab1HDFl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2011 01:41:57 -0400
Received: by wwe5 with SMTP id 5so1533709wwe.1
        for <netdev@vger.kernel.org>; Wed, 03 Aug 2011 22:41:56 -0700 (PDT)
In-Reply-To: <3571.1312405193@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/08/2011 22:59, Jay Vosburgh a =C3=A9crit :
> Nicolas de Peslo=C3=BCan<nicolas.2p.debian@gmail.com>  wrote:

<snip>

>> The obvious default value should be 1, but I cannot confirm it is.
>
> 	Looking at it now, I see no initialization, and it's a static,
> so I believe it will end up being zero.  From the code, zero seems li=
ke
> the proper default, since it will make this test never pass:
>
>                  /* are enough slaves available to consider link up? =
*/
>                  if (active->num_of_ports<  bond->params.min_links) {
>                          if (netif_carrier_ok(bond->dev)) {
>                                  netif_carrier_off(bond->dev);
>                                  return 1;
>                          }
>
> 	This will cause carrier to be asserted (for 802.3ad mode)
> whenever there is an active aggregator, regardless of the number of
> available links in that aggregator.
>
>> Stephen, as the author of this feature, can you please clarify what =
the default value for min_links is?
>>
>> V2 will follow, giving the real default value for all_slaves_active =
and
>> what I consider the sensible default value for max_links, even if th=
e
>> technical real default value is currently unclear.
>
> 	I think the actual and sensible default are both zero, although
> the documentation should probably mention that a value of zero is mag=
ic
> and won't ever set the bond down due to too few ports (links) active.
>
> 	Or, perhaps describe it how it actually works: if there are
> fewer than "min_links" ports in the active aggregator, the bond is se=
t
> carrier down.  The default min_links value of zero means that the bon=
d
> will never be set down due to having too few ports active.

Well, you are right, but for as far as I understand, using 1 as the def=
ault value for min_links=20
would cause the exact same behavior.

And 1 would be less "magical" and as such, more understandable from a u=
ser point of view. User might=20
understand min_links=3D0 as "assert carrier on if at least 0 link have =
carrier on", which might be=20
understood as "always assert carrier on".

	Nicolas.
