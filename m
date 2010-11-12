From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: Kernel rwlock design, Multicore and IGMP
Date: Fri, 12 Nov 2010 16:19:45 +0800
Message-ID: <20101112081945.GA5949@cr0.nay.redhat.com>
References: <AANLkTikvT=x9eBovn2-m6HLqk7wyXSAR3sc9jCQ0C6mL@mail.gmail.com>
 <1289489007.17691.1310.camel@edumazet-laptop>
 <AANLkTik93QUQxSDmwd4Qj-gXQiWWPzd68JPAYAHBAsHR@mail.gmail.com>
 <20101112071323.GB5660@cr0.nay.redhat.com>
 <1289546874.17691.1774.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>,
	Cypher Wu <cypher.w@gmail.com>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1289546874.17691.1774.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 12, 2010 at 08:27:54AM +0100, Eric Dumazet wrote:
>Le vendredi 12 novembre 2010 =C3=A0 15:13 +0800, Am=C3=A9rico Wang a =C3=
=A9crit :
>> On Fri, Nov 12, 2010 at 11:32:59AM +0800, Cypher Wu wrote:
>> >On Thu, Nov 11, 2010 at 11:23 PM, Eric Dumazet <eric.dumazet@gmail.=
com> wrote:
>> >> Le jeudi 11 novembre 2010 =C3=A0 21:49 +0800, Cypher Wu a =C3=A9c=
rit :
>> >>
>> >> Hi
>> >>
>> >> CC netdev, since you ask questions about network stuff _and_ rwlo=
ck
>> >>
>> >>
>> >>> I'm using TILEPro and its rwlock in kernel is a liitle different=
 than
>> >>> other platforms. It have a priority for write lock that when tri=
ed it
>> >>> will block the following read lock even if read lock is hold by
>> >>> others. Its code can be read in Linux Kernel 2.6.36 in
>> >>> arch/tile/lib/spinlock_32.c.
>> >>
>> >> This seems a bug to me.
>> >>
>> >> read_lock() can be nested. We used such a schem in the past in ip=
tables
>> >> (it can re-enter itself),
>> >> and we used instead a spinlock(), but with many discussions with =
lkml
>> >> and Linus himself if I remember well.
>> >>
>> >It seems not a problem that read_lock() can be nested or not since
>> >rwlock doesn't have 'owner', it's just that should we give
>> >write_lock() a priority than read_lock() since if there have a lot
>> >read_lock()s then they'll starve write_lock().
>> >We should work out a well defined behavior so all the
>> >platform-dependent raw_rwlock has to design under that principle.
>>=20
>
>AFAIK, Lockdep allows read_lock() to be nested.
>
>> It is a known weakness of rwlock, it is designed like that. :)
>>=20
>
>Agreed.
>

Just for record, both Tile and X86 implement rwlock with a write-bias,
this somewhat reduces the write-starvation problem.


>> The solution is to use RCU or seqlock, but I don't think seqlock
>> is proper for this case you described. So, try RCU lock.
>
>In the IGMP case, it should be easy for the task owning a read_lock() =
to
>pass a parameter to the called function saying 'I already own the
>read_lock(), dont try to re-acquire it'
>
>A RCU conversion is far more complex.
>

Yup.
