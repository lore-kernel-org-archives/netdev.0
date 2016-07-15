From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] rndis_host: Set random MAC for ZTE MF910
Date: Fri, 15 Jul 2016 19:42:28 +0200
Message-ID: <877fcmlrwb.fsf@miraculix.mork.no>
References: <1468427945-11600-1-git-send-email-kristian.evensen@gmail.com>
	<87k2gpnpo5.fsf@miraculix.mork.no>
	<063D6719AE5E284EB5DD2968C1650D6D5F4F921C@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kristian Evensen <kristian.evensen@gmail.com>,
	"linux-usb\@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D5F4F921C@AcuExch.aculab.com>
	(David Laight's message of "Fri, 15 Jul 2016 16:42:02 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Laight <David.Laight@ACULAB.COM> writes:
> From: Bj=C3=B8rn Mork
>> Sent: 13 July 2016 23:23
> ...
>> Or how about the more generic?:
>>=20
>>         if (bp[0] & 0x02)
>>    		eth_hw_addr_random(net);
>> 	else
>> 		ether_addr_copy(net->dev_addr, bp);
>>=20
>> That would catch similar screwups from other vendors too.
>
> Not really, that disables 'locally administered' addresses.

=2E.. when the 'locally administered' addresses comes from firmeare, ye=
s.
That was the idea.  We are better off using our own random locally
administered address if some vendor has been cheap/stupid enough to
program that into firmware.

The aminstrator is of course still free to set any address, 'locally
administered' or whatever.  This is not the question here.

> If a vendor has used the same address on lots of cards it could easil=
y
> be a 'real' address.

Sure.  We cannot easily detect that.  The only way is to keep a
blacklist of such  'real' addresses, the way Kristian initially
proposed.

But I thought that we could simplify this particular screwup since the
address in question had the local bit set, and catch every other simila=
r
abuse at the same time. If you get the local bit from formware, then yo=
u
know for sure that there is something wrong.

> Not only that, there certainly used to be manufacturers that used 'lo=
cally
> administered' addresses on all their cards (as well as those that use=
d unallocated
> address blocks).

Sure. But is there any reason to care about those addresses?

> Not to mention the bit-revered addresses....

Listing all the ways vendors have screwed is going to be a long and
rather boring thread ;)


Bj=C3=B8rn
