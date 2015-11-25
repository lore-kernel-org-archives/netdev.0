From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: use-after-free in sock_wake_async
Date: Wed, 25 Nov 2015 12:23:37 -0800
Message-ID: <1448483017.24696.33.camel@edumazet-glaptop2.roam.corp.google.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
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
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34445 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752208AbbKYUXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 15:23:40 -0500
In-Reply-To: <1448481002.24696.30.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-11-25 at 11:50 -0800, Eric Dumazet wrote:

> >                 other->sk_data_ready(other);
> > +               unix_state_unlock(other);


Also, problem with such construct is that we wakeup a thread that will
block on the lock we hold.

Beauty of sk_data_ready() is to call it once we hold no lock any more,
to enable another cpu to immediately proceed.

In this case, 'other' can not disappear, so it should be safe.
