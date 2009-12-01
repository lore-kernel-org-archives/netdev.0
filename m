From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] sch_htb: ix the deficit overflows
Date: Tue, 1 Dec 2009 10:32:26 +0800
Message-ID: <412e6f7f0911301832o53e479f0x42345065b0b1616f@mail.gmail.com>
References: <4B0F8A5D.1040806@gmail.com> <20091128000401.GA3713@ami.dom.local>
	 <412e6f7f0911292026w704a70b8yc3af2c2473e05d34@mail.gmail.com>
	 <20091130111020.GA7114@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Martin Devera <martin.devera@cdi.cz>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:39304 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017AbZLACcT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 21:32:19 -0500
Received: by pwi3 with SMTP id 3so2239593pwi.21
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2009 18:32:26 -0800 (PST)
In-Reply-To: <20091130111020.GA7114@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 30, 2009 at 7:10 PM, Jarek Poplawski <jarkao2@gmail.com> wr=
ote:
> On Mon, Nov 30, 2009 at 12:26:33PM +0800, Changli Gao wrote:
>
> Users can control this with "r2q" and "quantum", and there is a hint
> on quantum size in the user's guide.

Yes. But I think most of users will ignore it like me.

>
>> And
>> if we use IMQ to shape traffic, the skb will be defragmented by
>> conntrack, and its size will be larger than MTU.
>
> IMQ is a very nice thing, but it's considered broken as well, so it
> can't be the reason for changing HTB.

I find IMQ is used by many network equipments Linux based. Why not fix
and integrate it into official Linux?

> And this patch is very similar, except ->peek()/dequeue(). Additional
> lookups are done instead of dequeuing the first found class, which
> might be quite long in some cases.

If the quantum is set correctly, there isn't difference except of a
comparison. In the other case, I think some additional CPU cycles are
better than overflow.

>
> It's not acceptable to me mainly because the real change done by this
> patch is different than you describe: preventing an overflow might be
> simple. You change the way DRR is implemented here, and even if it's
> right, it should be written explicitly and proved with tests results.
>

This way is used by CBQ.

> Anyway, I think you should rather care for the author's acceptance,
> because the way it's done doesn't look like accidental and has been
> heavily tested btw. (I added Martin to CC.)
>
> Regards,
> Jarek P.
>
> PS: Btw, this newer version of the patch is broken with spaces.
>

Thanks. It is why I ask for posting again.



--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
