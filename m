From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: Kernel rwlock design, Multicore and IGMP
Date: Fri, 12 Nov 2010 15:13:23 +0800
Message-ID: <20101112071323.GB5660@cr0.nay.redhat.com>
References: <AANLkTikvT=x9eBovn2-m6HLqk7wyXSAR3sc9jCQ0C6mL@mail.gmail.com>
 <1289489007.17691.1310.camel@edumazet-laptop>
 <AANLkTik93QUQxSDmwd4Qj-gXQiWWPzd68JPAYAHBAsHR@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Cypher Wu <cypher.w@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:45174 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936Ab0KLHIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 02:08:40 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTik93QUQxSDmwd4Qj-gXQiWWPzd68JPAYAHBAsHR@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 12, 2010 at 11:32:59AM +0800, Cypher Wu wrote:
>On Thu, Nov 11, 2010 at 11:23 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
>> Le jeudi 11 novembre 2010 =C3=A0 21:49 +0800, Cypher Wu a =C3=A9crit=
 :
>>
>> Hi
>>
>> CC netdev, since you ask questions about network stuff _and_ rwlock
>>
>>
>>> I'm using TILEPro and its rwlock in kernel is a liitle different th=
an
>>> other platforms. It have a priority for write lock that when tried =
it
>>> will block the following read lock even if read lock is hold by
>>> others. Its code can be read in Linux Kernel 2.6.36 in
>>> arch/tile/lib/spinlock_32.c.
>>
>> This seems a bug to me.
>>
>> read_lock() can be nested. We used such a schem in the past in iptab=
les
>> (it can re-enter itself),
>> and we used instead a spinlock(), but with many discussions with lkm=
l
>> and Linus himself if I remember well.
>>
>It seems not a problem that read_lock() can be nested or not since
>rwlock doesn't have 'owner', it's just that should we give
>write_lock() a priority than read_lock() since if there have a lot
>read_lock()s then they'll starve write_lock().
>We should work out a well defined behavior so all the
>platform-dependent raw_rwlock has to design under that principle.

It is a known weakness of rwlock, it is designed like that. :)

The solution is to use RCU or seqlock, but I don't think seqlock
is proper for this case you described. So, try RCU lock.
