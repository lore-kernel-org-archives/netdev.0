From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: Re: [PATCH 1/3] ssb: add missing method ssb_gige_get_macaddr
Date: Sun, 13 Jan 2013 23:31:58 +0100
Message-ID: <50F335DE.5020306@hauke-m.de>
References: <1358020905-9924-1-git-send-email-hauke@hauke-m.de> <1358020905-9924-2-git-send-email-hauke@hauke-m.de> <20130112.153211.562541025115995797.davem@davemloft.net> <20130113104729.37b9fa03@milhouse>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, mcarlson@broadcom.com,
	mchan@broadcom.com, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Michael_B=FCsch?= <m@bues.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:57342 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755774Ab3AMWcL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Jan 2013 17:32:11 -0500
In-Reply-To: <20130113104729.37b9fa03@milhouse>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 01/13/2013 10:47 AM, Michael B=FCsch wrote:
> On Sat, 12 Jan 2013 15:32:11 -0800 (PST) David Miller
> <davem@davemloft.net> wrote:
>=20
>> From: Hauke Mehrtens <hauke@hauke-m.de> Date: Sat, 12 Jan 2013
>> 21:01:43 +0100
>>=20
>>> When CONFIG_SSB_DRIVER_GIGE is not set the header does not
>>> provide the needed method.
>>>=20
>>> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
>>=20
>> This isn't right.
>>=20
>> You can't implement this function in a way that the caller
>> cannot determine that it didn't actually do anything.
>>=20
>> You either have to protect calls with ifdefs or make this
>> routine return an error indication, in response to which the
>> caller can set a random ethernet address or take some other
>> corrective action.
>=20
> tg3 uses is_valid_ether_addr() afterwards anyway. An error code
> return value could be added, but it didn't seem necessary.

David, I could change that function to return an error code in this
case, but this stub should never get called, because a caller should
check if this device is a ssb gige core with pdev_is_ssb_gige_core()
before and this always returns false if CONFIG_SSB_DRIVER_GIGE is not s=
et.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iQIcBAEBAgAGBQJQ8zXWAAoJEIZ0px9YPRMyFgEP/Rz1BOXwbHawvupAWKCLdhm5
UquCnygVZrsbskN63c5R4OfVXGZ6UFihbf1xKHq4IRv9UXkNdymoiCmv6sUVfkjR
=46emyqRZ4QOz08cbVhb0k0nEIpVguyf16063kGo4JHIGAZc54xruMZv54uZYOfvvR
GYbTsVbkzNvW2ArVesGGYjbKHyEyOmjqW5GvjyyH72cQK+vZI8PBRC8tO9l8d3D1
pq3KnHSeOEXBbODgWC36QmcMV8EEQ4BAxJQjsABXO7KRyu0HpAu7zSEn8aGhV4ln
X1q6WMzPQIOjJhmxJUGbnJEo1s05/AjT2lIU7J7QcHN21YQqIUjWzG9lYCWcbhX/
RloFjEk/Gf80CfzJj97RCLKiJScfa8tdbvFvisDZaQVbet7Ql5nHeRSyiMTzMFKi
oivkh3gmaN/2CE8rgj5QIiL3DSzy0MY2cbTZMx3QmYAlTQ52cTT3NLRaT5RKxv3c
gAUq0EvkOZhHKo/WkBWbI/V4p4CWNhJI/wNphHuOM7lJ3kvfITXw17+/29rywkZY
pB5TwdlQBtuRUjAbXvUJmfIAZE1p4bd9+0liW+qPlpoa1d7ZOaTWPhxUg+74kvgP
rItNpGf9RAb7/A/n9XjciemihcMpEH4BjShgJVNN66+LwfbQ2ZRNGsJfyJZGcYEO
n7qAWVoPmgKihES59NtA
=3D1JMZ
-----END PGP SIGNATURE-----
