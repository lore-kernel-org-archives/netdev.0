From: Cypher Wu <cypher.w@gmail.com>
Subject: Re: [PATCH] arch/tile: fix rwlock so would-be write lockers don't
 block new readers
Date: Wed, 24 Nov 2010 10:53:17 +0800
Message-ID: <AANLkTinx3pcJHGrQq_C-Rgk5g7SxjmpTcD0A50d8d48b@mail.gmail.com>
References: <AANLkTikvT=x9eBovn2-m6HLqk7wyXSAR3sc9jCQ0C6mL@mail.gmail.com>
	<1289489007.17691.1310.camel@edumazet-laptop>
	<AANLkTik93QUQxSDmwd4Qj-gXQiWWPzd68JPAYAHBAsHR@mail.gmail.com>
	<ZXmP8hjgLHA.4648@exchange1.tad.internal.tilera.com>
	<4CDF1945.8090101@tilera.com>
	<AANLkTind92uwcigzmDn8yn9a22exDy7zcreGQ5-6NLV-@mail.gmail.com>
	<201011151425.oAFEPU3W005682@farm-0010.internal.tilera.com>
	<AANLkTikGj+zG9OqVJseKh4fGqQNnqnJpHgcaaXOL8nNi@mail.gmail.com>
	<4CEA71AD.5010606@tilera.com>
	<AANLkTim1YyujwGZfenU_m52HEJJSFmTg3Wswn2DkqA3a@mail.gmail.com>
	<4CEC2BE7.4060205@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org,
	=?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CEC2BE7.4060205@tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2010/11/24 Chris Metcalf <cmetcalf@tilera.com>:
> On 11/22/2010 8:36 PM, Cypher Wu wrote:
>> Say, if core A try to write_lock() rwlock and current_ticket_ is 0 and
>> it write next_ticket_ to 1, when it processing the lock, core B try to
>> write_lock() again and write next_ticket_ to 2, then when A
>> write_unlock() it seen that (current_ticket_+1) is not equal to
>> next_ticket_, so it increment current_ticket_, and core B get the
>> lock. If core A try write_lock again before core B write_unlock, it
>> will increment next_ticket_ to 3. And so on.
>> This may rarely happened, I've tested it yesterday for several hours
>> it goes very well under pressure.
>
> This should be OK when it happens (other than starving out the readers, but
> that was the decision made by doing a ticket lock in the first place).
> Even if we wrap around 255 back to zero on the tickets, the ticket queue
> will work correctly.  The key is not to need more than 256 concurrent write
> lock waiters, which we don't.
>
> --
> Chris Metcalf, Tilera Corp.
> http://www.tilera.com
>
>

If we count on that, should we make 'my_ticket_ = (val >>
WR_NEXT_SHIFT) & WR_MASK;'?

-- 
Cyberman Wu
http://www.meganovo.com
