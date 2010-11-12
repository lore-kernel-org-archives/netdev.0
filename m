From: Cypher Wu <cypher.w@gmail.com>
Subject: Re: Kernel rwlock design, Multicore and IGMP
Date: Fri, 12 Nov 2010 19:10:58 +0800
Message-ID: <AANLkTikHjGkq5FDoXHaUbRkpurmT3mSLiu8toqqRL4Gi@mail.gmail.com>
References: <AANLkTikvT=x9eBovn2-m6HLqk7wyXSAR3sc9jCQ0C6mL@mail.gmail.com>
	<1289489007.17691.1310.camel@edumazet-laptop>
	<AANLkTik93QUQxSDmwd4Qj-gXQiWWPzd68JPAYAHBAsHR@mail.gmail.com>
	<20101112071323.GB5660@cr0.nay.redhat.com>
	<1289546874.17691.1774.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1289546874.17691.1774.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 12, 2010 at 3:27 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le vendredi 12 novembre 2010 =E0 15:13 +0800, Am=E9rico Wang a =E9cri=
t :
>> On Fri, Nov 12, 2010 at 11:32:59AM +0800, Cypher Wu wrote:
>> >On Thu, Nov 11, 2010 at 11:23 PM, Eric Dumazet <eric.dumazet@gmail.=
com> wrote:
>> >> Le jeudi 11 novembre 2010 =E0 21:49 +0800, Cypher Wu a =E9crit :
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
>>
>
> AFAIK, Lockdep allows read_lock() to be nested.
>
>> It is a known weakness of rwlock, it is designed like that. :)
>>
>
> Agreed.
>
>> The solution is to use RCU or seqlock, but I don't think seqlock
>> is proper for this case you described. So, try RCU lock.
>
> In the IGMP case, it should be easy for the task owning a read_lock()=
 to
> pass a parameter to the called function saying 'I already own the
> read_lock(), dont try to re-acquire it'

I used to using that way, just seperate the call internal and
external, with external one hold lock then call the internal one. But
in that case ip_check_mc() is called indirectly from igmpv3_sendpack()
and is not very clear how to give the different paramter?

>
> A RCU conversion is far more complex.
>
>
>
>
