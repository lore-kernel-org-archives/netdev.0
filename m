From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: filter: Convert the BPF VM to threaded code
Date: Mon, 01 Aug 2011 17:57:05 -0700 (PDT)
Message-ID: <20110801.175705.2074393848482150971.davem@davemloft.net>
References: <CACKH++ZfNTB7Y8YhvQnZPEXpwmpWXzxQgnWniamDrjRWUwxaNw@mail.gmail.com>
	<20110801181652.GB2732@nuttenaction>
	<1312223866.2719.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hagen@jauu.net, rui314@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58050 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752687Ab1HBA5L convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 20:57:11 -0400
In-Reply-To: <1312223866.2719.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 01 Aug 2011 20:37:46 +0200

> Le lundi 01 ao=FBt 2011 =E0 20:16 +0200, Hagen Paul Pfeifer a =E9crit=
 :
>> * Rui Ueyama | 2011-07-29 01:10:26 [-0700]:
>>=20
>> >Convert the BPF VM to threaded code to improve performance.
>> >
>> >The BPF VM is basically a big for loop containing a switch statemen=
t.  That is
>> >slow because for each instruction it checks the for loop condition =
and does the
>> >conditional branch of the switch statement.
>> >
>> >This patch eliminates the conditional branch, by replacing it with =
jump table
>> >using GCC's labels-as-values feature. The for loop condition check =
can also be
>> >removed, because the filter code always end with a RET instruction.
>>=20
>> With commit 01f2f3f6ef4d076c I reworked the BPF code so that gcc is =
in the
>> ability to generate a jump table, I double checked this. Not sure wh=
at happened
>> in the meantime.
>>=20
>=20
> A switch() always generates one conditional branch, catching values n=
ot
> enumerated in the "case ..." clauses.

Maybe it won't if we use an enum and make sure all enum values are hand=
led
in the switch? :-)
