From: David Miller <davem@davemloft.net>
Subject: Re: Gaah: selinux_socket_unix_stream_connect oops
Date: Wed, 05 Jan 2011 15:38:12 -0800 (PST)
Message-ID: <20110105.153812.242136718.davem@davemloft.net>
References: <AANLkTikPvJLEZetB-CbVSO0VuYLnAQz5y8D_F0HGML=5@mail.gmail.com>
	<20110105.142540.245404254.davem@davemloft.net>
	<AANLkTimZnqQ1xmQC2Bp3vj60uU_vPEwWi2n+G9MZ4Uo9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jeremy@goop.org, jmorris@namei.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47310
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752934Ab1AEXhl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jan 2011 18:37:41 -0500
In-Reply-To: <AANLkTimZnqQ1xmQC2Bp3vj60uU_vPEwWi2n+G9MZ4Uo9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 5 Jan 2011 15:32:44 -0800

> On Wed, Jan 5, 2011 at 2:25 PM, David Miller <davem@davemloft.net> wr=
ote:
>>
>> More seriously, we can get at the struct socket via sk->sk_socket in
>> the SMACK code. =A0sk->sk_socket, unlike socket->sk, has it's state
>> change to NULL (via sock_orphen()) protected by unix_state_lock(),
>> which we hold for "other" in this unix connect code path.
>>
>> Therefore I propose we fix this like so:
>=20
> Looks fine to me.
>=20
> And no, I don't think that selinux is all the world, but selinux is
> the _common_ case, and with the cross-pointers, the only difference
> can be whether you need to dereference the pointer or not - so
> choosing the "extra dereference" case for the common case seems silly=
=2E
>=20
> The fact that this also fixes locking is obviously an even better
> reason to do it, though ;)

Right :)

I'll toss this your way during the merge window and queue it up for
later -stable submission as well.

Thanks.
