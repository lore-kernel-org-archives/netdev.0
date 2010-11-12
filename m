From: Yong Zhang <yong.zhang0@gmail.com>
Subject: Re: Kernel rwlock design, Multicore and IGMP
Date: Fri, 12 Nov 2010 17:09:45 +0800
Message-ID: <AANLkTik-KDvc2fgH91vBHGT6vqxbZrv=9DoQknujPWy2@mail.gmail.com>
References: <AANLkTikvT=x9eBovn2-m6HLqk7wyXSAR3sc9jCQ0C6mL@mail.gmail.com>
	<1289489007.17691.1310.camel@edumazet-laptop>
	<AANLkTik93QUQxSDmwd4Qj-gXQiWWPzd68JPAYAHBAsHR@mail.gmail.com>
	<20101112071323.GB5660@cr0.nay.redhat.com>
	<1289546874.17691.1774.camel@edumazet-laptop>
	<20101112081945.GA5949@cr0.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Cypher Wu <cypher.w@gmail.com>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:51220 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755413Ab0KLJJs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 04:09:48 -0500
In-Reply-To: <20101112081945.GA5949@cr0.nay.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 12, 2010 at 4:19 PM, Am=C3=A9rico Wang <xiyou.wangcong@gmai=
l.com> wrote:
> On Fri, Nov 12, 2010 at 08:27:54AM +0100, Eric Dumazet wrote:
>>Le vendredi 12 novembre 2010 =C3=A0 15:13 +0800, Am=C3=A9rico Wang a =
=C3=A9crit :
>>> On Fri, Nov 12, 2010 at 11:32:59AM +0800, Cypher Wu wrote:
>>> >On Thu, Nov 11, 2010 at 11:23 PM, Eric Dumazet <eric.dumazet@gmail=
=2Ecom> wrote:
>>> >> Le jeudi 11 novembre 2010 =C3=A0 21:49 +0800, Cypher Wu a =C3=A9=
crit :
>>> >>
>>> >> Hi
>>> >>
>>> >> CC netdev, since you ask questions about network stuff _and_ rwl=
ock
>>> >>
>>> >>
>>> >>> I'm using TILEPro and its rwlock in kernel is a liitle differen=
t than
>>> >>> other platforms. It have a priority for write lock that when tr=
ied it
>>> >>> will block the following read lock even if read lock is hold by
>>> >>> others. Its code can be read in Linux Kernel 2.6.36 in
>>> >>> arch/tile/lib/spinlock_32.c.
>>> >>
>>> >> This seems a bug to me.
>>> >>
>>> >> read_lock() can be nested. We used such a schem in the past in i=
ptables
>>> >> (it can re-enter itself),
>>> >> and we used instead a spinlock(), but with many discussions with=
 lkml
>>> >> and Linus himself if I remember well.
>>> >>
>>> >It seems not a problem that read_lock() can be nested or not since
>>> >rwlock doesn't have 'owner', it's just that should we give
>>> >write_lock() a priority than read_lock() since if there have a lot
>>> >read_lock()s then they'll starve write_lock().
>>> >We should work out a well defined behavior so all the
>>> >platform-dependent raw_rwlock has to design under that principle.
>>>
>>
>>AFAIK, Lockdep allows read_lock() to be nested.
>>
>>> It is a known weakness of rwlock, it is designed like that. :)
>>>
>>
>>Agreed.
>>
>
> Just for record, both Tile and X86 implement rwlock with a write-bias=
,
> this somewhat reduces the write-starvation problem.

Are you sure(on x86)?

It seems that we never realize writer-bias rwlock.

Thanks,
Yong
>
>
>>> The solution is to use RCU or seqlock, but I don't think seqlock
>>> is proper for this case you described. So, try RCU lock.
>>
>>In the IGMP case, it should be easy for the task owning a read_lock()=
 to
>>pass a parameter to the called function saying 'I already own the
>>read_lock(), dont try to re-acquire it'
>>
>>A RCU conversion is far more complex.
>>
>
> Yup.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
> Please read the FAQ at =C2=A0http://www.tux.org/lkml/
>
