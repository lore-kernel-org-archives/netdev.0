From: Cypher Wu <cypher.w@gmail.com>
Subject: Re: Kernel rwlock design, Multicore and IGMP
Date: Mon, 15 Nov 2010 15:22:02 +0800
Message-ID: <AANLkTind92uwcigzmDn8yn9a22exDy7zcreGQ5-6NLV-@mail.gmail.com>
References: <AANLkTikvT=x9eBovn2-m6HLqk7wyXSAR3sc9jCQ0C6mL@mail.gmail.com>
	<1289489007.17691.1310.camel@edumazet-laptop>
	<AANLkTik93QUQxSDmwd4Qj-gXQiWWPzd68JPAYAHBAsHR@mail.gmail.com>
	<ZXmP8hjgLHA.4648@exchange1.tad.internal.tilera.com>
	<4CDF1945.8090101@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:63869 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757527Ab0KOHWE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 02:22:04 -0500
In-Reply-To: <4CDF1945.8090101@tilera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 14, 2010 at 7:03 AM, Chris Metcalf <cmetcalf@tilera.com> wr=
ote:
> On 11/12/2010 2:13 AM, Am=E9rico Wang wrote:
>> On Fri, Nov 12, 2010 at 11:32:59AM +0800, Cypher Wu wrote:
>>> On Thu, Nov 11, 2010 at 11:23 PM, Eric Dumazet <eric.dumazet@gmail.=
com> wrote:
>>>> Le jeudi 11 novembre 2010 =E0 21:49 +0800, Cypher Wu a =E9crit :
>>>>> I'm using TILEPro and its rwlock in kernel is a liitle different =
than
>>>>> other platforms. It have a priority for write lock that when trie=
d it
>>>>> will block the following read lock even if read lock is hold by
>>>>> others. Its code can be read in Linux Kernel 2.6.36 in
>>>>> arch/tile/lib/spinlock_32.c.
>>>>
>>>> This seems a bug to me.
>>>> [...]
>>>>
>>> It seems not a problem that read_lock() can be nested or not since
>>> rwlock doesn't have 'owner', it's just that should we give
>>> write_lock() a priority than read_lock() since if there have a lot
>>> read_lock()s then they'll starve write_lock().
>>> We should work out a well defined behavior so all the
>>> platform-dependent raw_rwlock has to design under that principle.
>>
>> It is a known weakness of rwlock, it is designed like that. :)
>
> Exactly.  The tile rwlock correctly allows recursively reacquiring th=
e read
> lock.  But it does give priority to writers, for the (unfortunately
> incorrect) reasons Cypher Wu outlined above, e.g.:
>
> - Core A takes a read lock
> - Core B tries for a write lock and blocks new read locks
> - Core A tries for a (recursive) read lock and blocks
>
> Core A and B are now deadlocked.
>
> The solution is actually to simplify the tile rwlock implementation s=
o that
> both readers and writers contend fairly for the lock.
>
> I'll post a patch in the next day or two for tile.
>
> --
> Chris Metcalf, Tilera Corp.
> http://www.tilera.com
>

We're looking forward to you patch. BTW: could your fix it up in Linux
2.6.26.7 which is not release in the normal kernel?

--=20
Cyberman Wu
http://www.meganovo.com
