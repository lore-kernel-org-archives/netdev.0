From: Zdenek Radouch <zdenek@rcn.com>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: Sun, 06 Mar 2005 16:50:55 -0500
Message-ID: <3sp35g$7hpm0@smtp04.mrf.mail.rcn.net>
References: <m1y8d0mss2.fsf@muc.de>
 <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
 <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
 <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
 <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
 <20050306173145.GQ31837@postel.suug.ch>
 <E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net>
 <m1y8d0mss2.fsf@muc.de> <20050306204516.GR31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Martin Mares <mj@ucw.cz>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>, Andi Kleen <ak@muc.de>
In-Reply-To: <20050306204516.GR31837@postel.suug.ch>
References: <m1y8d0mss2.fsf@muc.de>
 <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
 <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
 <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
 <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
 <20050306173145.GQ31837@postel.suug.ch>
 <E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net>
 <m1y8d0mss2.fsf@muc.de>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

OK.  We've gone a full circle, [except for a few digressions
along the lines of me not knowing that while the rest of the
world still uses 'route', under linux it has long been deprecated]
you seem to be agreeing with my original guess that 
subnetting the 127 net may not be trivial, and that it may require
some kernel hacking.

So my original questions still stand:

1) How could one remove the special kernel treatment of the 127 net?
    [so that "lo" gets 127.0.0.1/16 and "foo" gets 127.1.0.1/16, and
    so that the "foo" interface can actually receive packets?

2) If it does require kernel hacking, would you like to do it for me?
    (as I had said, as a contract)


>> it won't accept outside packets with a loopback address.

Not accepting packets with with a loopback address is one
thing, not accepting any 127.0.0.0/8 packets is entirely something else.

Couldn't that whole 127 thing be ripped out of the kernel?
Why couldn't the "lo" interface be treated as any other interface?

-Zdenek





At 09:45 PM 3/6/05 +0100, Thomas Graf wrote:
>* Andi Kleen <m1y8d0mss2.fsf@muc.de> 2005-03-06 21:19
>> Zdenek Radouch <zdenek@rcn.com> writes:
>> >
>> > There is no doubt that the 127.x net is treated in a special
>> > way.  If I have to believe what I just learned, then the 127
>> 
>> It is. 127.* is hardcoded in the routing engine and e.g.
>> it won't accept outside packets with a loopback address.
>> 
>> Most likely it's enough to change the "LOOPBACK" macro to allow
>> parts of the Class A to be used for other purposes.
>
>Yes, it will work around the martian route and arp checks but
>will probably break quite a few usersapce applications.
> 
