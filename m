From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [RFC PATCH 7/8] [SCTP]: uninline sctp_add_cmd_sf
Date: Thu, 21 Feb 2008 10:27:46 -0500
Message-ID: <47BD9872.9050308@hp.com>
References: <1203515238-22848-1-git-send-email-ilpo.jarvinen@helsinki.fi> <1203515238-22848-2-git-send-email-ilpo.jarvinen@helsinki.fi> <1203515238-22848-3-git-send-email-ilpo.jarvinen@helsinki.fi> <1203515238-22848-4-git-send-email-ilpo.jarvinen@helsinki.fi> <1203515238-22848-5-git-send-email-ilpo.jarvinen@helsinki.fi> <1203515238-22848-6-git-send-email-ilpo.jarvinen@helsinki.fi> <1203515238-22848-7-git-send-email-ilpo.jarvinen@helsinki.fi> <1203515238-22848-8-git-send-email-ilpo.jarvinen@helsinki.fi> <47BCA6B8.5000904@hp.com> <Pine.LNX.4.64.0802210020350.17063@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:6806 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753775AbYBUP1f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 10:27:35 -0500
In-Reply-To: <Pine.LNX.4.64.0802210020350.17063@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:
> On Wed, 20 Feb 2008, Vlad Yasevich wrote:
>=20
>> Ilpo J=E4rvinen wrote:
>>> I added inline to sctp_add_cmd and appropriate comment there to
>>> avoid adding another call into the call chain. This works at least
>>> with "gcc (GCC) 4.1.2 20070626 (Red Hat 4.1.2-13)". Alternatively,
>>> __sctp_add_cmd could be introduced to .h.
>>>
>> My only concern was performance regressions, but it looks like it
>> doesn't effect anything from the few quick runs I've made.
>=20
> There was one call made anyway, it's a bit hard to see how it would h=
urt=20
> to push that BUG() deeper down (in fact, this is one of the easiest c=
ase=20
> in this respect, many other cases elsewhere that need uninlining don'=
t=20
> currently make any calls with inlines).
>=20
>> Since we are putting sctp_add_cmd_sf() on the call stack, we might
>> as well get rid of sctp_add_cmd() and reduce it a bit more.
>=20
> IMHO it is definately better solution for archiving the size reductio=
n,
> I just didn't know before that the only sctp_add_cmd call could be=20
> converted.

That one was a really silly one.  The chance of not calling BUG() in
that one case was so small, that it didn't really make any sense from
the code robustness side.

>=20
> [...snip...]
>> diff --git a/net/sctp/command.c b/net/sctp/command.c
>> index bb97733..3a06513 100644
>> --- a/net/sctp/command.c
>> +++ b/net/sctp/command.c
>> @@ -51,19 +51,16 @@ int sctp_init_cmd_seq(sctp_cmd_seq_t *seq)
>> =20
>>  /* Add a command to a sctp_cmd_seq_t.
>>   * Return 0 if the command sequence is full.
>> + *
>> + * Inline here is not a mistake, this way sctp_add_cmd_sf doesn't n=
eed extra
>> + * calls, size penalty is of insignificant magnitude here
>=20
> This won't be a necessary note anymore. :-)
>=20
> [...snip...]
>=20

Yeah.  If you are going to resubmit, feel free to put my Signed-off-by =
line.

-vlad
