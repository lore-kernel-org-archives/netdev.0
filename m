From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v4 6/7] rocker: remove nowait from switchdev callbacks.
Date: Mon, 12 Oct 2015 23:55:11 -0700
Message-ID: <CAE4R7bAayOFtATyoTxm56e7gbSifkKt51mUeFa8-wL0FrKjHDA@mail.gmail.com>
References: <1444672467-20621-1-git-send-email-jiri@resnulli.us>
 <1444672986-20709-1-git-send-email-jiri@resnulli.us> <1444672986-20709-5-git-send-email-jiri@resnulli.us>
 <CAE4R7bDfDCEGcHY=y+77DbC0z09ogN9jiO_qBhb+utwXTUzmHw@mail.gmail.com> <20151013062530.GE2242@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	john fastabend <john.fastabend@gmail.com>,
	David Laight <David.Laight@aculab.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:33790 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751914AbbJMGzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 02:55:31 -0400
Received: by oiar126 with SMTP id r126so4525352oia.0
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 23:55:31 -0700 (PDT)
In-Reply-To: <20151013062530.GE2242@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 12, 2015 at 11:25 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Tue, Oct 13, 2015 at 06:02:28AM CEST, sfeldma@gmail.com wrote:
>>On Mon, Oct 12, 2015 at 11:03 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> From: Jiri Pirko <jiri@mellanox.com>
>>>
>>> No need to avoid sleeping in switchdev callbacks now, as the switchdev
>>> core allows it.
>>>
>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>>> ---
>>>  drivers/net/ethernet/rocker/rocker.c | 7 +++----
>>>  1 file changed, 3 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>>> index bb956a5..9629c5b5 100644
>>> --- a/drivers/net/ethernet/rocker/rocker.c
>>> +++ b/drivers/net/ethernet/rocker/rocker.c
>>> @@ -3672,7 +3672,7 @@ static int rocker_port_fdb_flush(struct rocker_port *rocker_port,
>>>             rocker_port->stp_state == BR_STATE_FORWARDING)
>>>                 return 0;
>>>
>>> -       flags |= ROCKER_OP_FLAG_REMOVE;
>>> +       flags |= ROCKER_OP_FLAG_NOWAIT | ROCKER_OP_FLAG_REMOVE;
>>
>>I understand the two changes below where you're removing NOWAIT, but
>>here you're adding NOWAIT which I'm not sure how that is related to
>>the switchdev core changes.  Is this two patches?
>
> I removed ROCKER_OP_FLAG_NOWAIT from attr_set. But here in
> rocker_port_fdb_flush, which is called from attr_set, we call
> rocker_port_fdb_learn with spin lock. Therefore I had to put
> ROCKER_OP_FLAG_NOWAIT here. Before ROCKER_OP_FLAG_NOWAIT removal from
> attr_set this was there already.

Gotcha.

Acked-by: Scott Feldman <sfeldma@gmail.com>
