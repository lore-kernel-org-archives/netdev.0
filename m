From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: use-after-free in sock_wake_async
Date: Wed, 25 Nov 2015 20:57:59 +0000
Message-ID: <87two93ig8.fsf@doppelsaurus.mobileactivedefense.com>
References: <CACT4Y+ZZQ0ooT9LekV35u_jUAtAHJfg5O5SD=xATfHUF5UdNBQ@mail.gmail.com>
	<CANn89i+Uw+YzhRbQVSyf=FAQBO06JfFoxQpSHxfmDpS5_iZBQw@mail.gmail.com>
	<87poyzj7j2.fsf@doppelsaurus.mobileactivedefense.com>
	<CANn89iKg0Lc7OVLhxUOzPRr4OhEGxA8L7V1jyaqFAS6+7kEXTA@mail.gmail.com>
	<87io4qevdp.fsf@doppelsaurus.mobileactivedefense.com>
	<CANn89iJgW+6giMUicU1m831+mkaNy9z1hQB-ixvRHBqZo-7Yig@mail.gmail.com>
	<87io4q3u8u.fsf@doppelsaurus.mobileactivedefense.com>
	<1448471494.24696.18.camel@edumazet-glaptop2.roam.corp.google.com>
	<87a8q23s2a.fsf@doppelsaurus.mobileactivedefense.com>
	<1448473891.24696.21.camel@edumazet-glaptop2.roam.corp.google.com>
	<87610q3pjg.fsf@doppelsaurus.mobileactivedefense.com>
	<1448476744.24696.25.camel@edumazet-glaptop2.roam.corp.google.com>
	<87y4dl3m5c.fsf@doppelsaurus.mobileactivedefense.com>
	<1448481002.24696.30.camel@edumazet-glaptop2.roam.corp.google.com>
	<1448483017.24696.33.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Eric Dumazet <edumazet@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Benjamin LaHaise <bcrl@kvack.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	David Howells <dhowells@redhat.com>,
	Ying Xue <ying.xue@windriver.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448483017.24696.33.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Wed, 25 Nov 2015 12:23:37 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> writes:
> On Wed, 2015-11-25 at 11:50 -0800, Eric Dumazet wrote:
>
>> >                 other->sk_data_ready(other);
>> > +               unix_state_unlock(other);
>
>
> Also, problem with such construct is that we wakeup a thread that will
> block on the lock we hold.
>
> Beauty of sk_data_ready() is to call it once we hold no lock any more,
> to enable another cpu to immediately proceed.
>
> In this case, 'other' can not disappear, so it should be safe.

I do agree that keeping the ->sk_data_ready outside of the lock will
very likely have performance advantages. That's just something I
wouldn't have undertaken because I'd be reluctant to make a fairly
complicated change to a lot of code in order to improve performance
unless performance was actually found to be lacking and because it would
step onto to many different people's turf.
