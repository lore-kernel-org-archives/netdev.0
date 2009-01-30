From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] netfilter: unfold two critical loops in ip_packet_match()
Date: Fri, 30 Jan 2009 18:27:37 +0100
Message-ID: <49833889.4000201@cosmosbay.com>
References: <497F4C2F.9000804@hp.com> <497F5BCD.9060807@hp.com> <497F5F86.9010101@hp.com> <498063E7.5030106@cosmosbay.com> <49808708.3050502@trash.net> <498090C1.5020400@cosmosbay.com> <49809716.3020204@cosmosbay.com> <4981CBE2.5020306@cosmosbay.com> <87ocxox0bu.fsf@basil.nowhere.org> <498330B2.4060004@cosmosbay.com> <20090130172705.GB18453@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090130172705.GB18453@one.firstfloor.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen a =E9crit :
> On Fri, Jan 30, 2009 at 05:54:10PM +0100, Eric Dumazet wrote:
>> Andi Kleen a =E9crit :
>>> Eric Dumazet <dada1@cosmosbay.com> writes:
>>>
>>>> While doing oprofile tests I noticed two loops are not properly un=
rolled by gcc
>>> That's because nobody passed -funroll-loops. Did you try that for
>>> that file? Likely will need -O2 too
>> I dont want to unroll all loops, only those two :)
>=20
> gcc 4.4 will have a way to do that per function, but earlier
> you would need to move it to a separate file and specify
> the option only for that.
>=20
> Doing so would be still a good idea compared to your
> patch because the code will be cleaner and might
> be more adaptable to future architectures
> (such manual tunings tend to outdate)

So... you suggest me to split file, and use a "-funroll-loops",
that might doing strange things on some arches / compilers...

This is far too complicated and risky imho.

Check compare_ether_addr_64bits() definition in=20
include/linux/etherdevice.h for a truly unreadable code :)


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
