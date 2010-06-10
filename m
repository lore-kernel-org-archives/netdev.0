From: Sonic Zhang <sonic.adi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3] netdev:bfin_mac: reclaim and
	free tx skb as soon as possible after transfer
Date: Thu, 10 Jun 2010 17:44:02 +0800
Message-ID: <AANLkTikBpghBJ7P4Lg080a7lM4eE2jRy4OvtzmjRgODO@mail.gmail.com>
References: <1275907104.9082.1.camel@eight.analog.com>
	<20100607.212238.209978119.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
In-Reply-To: <20100607.212238.209978119.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://blackfin.uclinux.org/mailman/options/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=unsubscribe>
List-Archive: <http://blackfin.uclinux.org/pipermail/uclinux-dist-devel>
List-Post: <mailto:uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
List-Help: <mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=help>
List-Subscribe: <https://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=subscribe>
Sender: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
Errors-To: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 8, 2010 at 12:22 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> From: sonic zhang <sonic.adi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Mon, 7 Jun 2010 18:38:24 +0800
>
>>
>> + =A0 =A0 if (timer_pending(&lp->tx_reclaim_timer))
>> + =A0 =A0 =A0 =A0 =A0 =A0 del_timer(&(lp->tx_reclaim_timer));
>> +
>
> Please remove the excess parenthesis around lp->tx_reclaim_timer being
> passed to del_timer().
>
> Also, you can unconditionally call del_timer(). =A0If the timer isn't run=
ning
> the call won't do anything.

OK

>
> But you have to do something to make sure you don't race with the code th=
at
> enables the timer, f.e. what keeps the timer from being scheduled right
> after you make this del_timer() call?
>
Sorry, I don't understand. If the timer is removed from the timer base
list,  how can it be scheduled? Timeout callbacks are scheduled only
in __run_timers() in soft irq handler.  Timer base list is protected
by a spinlock. After a timer is removed from the list, __run_timers()
won't triggers it any more.

Does I miss something here?

Thanks

Sonic
