From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [RFC 2/4] bpf, security: Add Checmate
Date: Fri, 5 Aug 2016 15:45:42 +0800
Message-ID: <CAD=hENc1tqWKD9GBPExyAZh_DhzSx_qfQjSMRUCzK8NJDDQqfQ@mail.gmail.com>
References: <20160804071140.GA19121@ircssh.c.rugged-nimbus-611.internal>
 <CAD=hENfPUmP6odm+oFg0gAEJ5oqKksTyZPYE1F1iXJW=DS7sqQ@mail.gmail.com>
 <1470299302.13693.13.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAD=hENeWDNTQ8oQurdX6kHxuuRVh-DtEDEDH0=-BCM9mqzZn6g@mail.gmail.com> <20160805070504.GA5971@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	alexei.starovoitov@gmail.com, daniel@iogearbox.net,
	linux-security-module@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160805070504.GA5971@ircssh.c.rugged-nimbus-611.internal>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Sure.
Why are preempt_disable and rcu_read_lock used here? is there a great
benefit of dong this?

On Fri, Aug 5, 2016 at 3:05 PM, Sargun Dhillon <sargun@sargun.me> wrote:
> On Thu, Aug 04, 2016 at 05:34:32PM +0800, zhuyj wrote:
>>  Sure.
>> Is it better to add
>> #ifndef CONFIG_PREEMPT_RCU ?
>>
>> On Thu, Aug 4, 2016 at 4:28 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > Please do not top post
>> >
>> > On Thu, 2016-08-04 at 16:08 +0800, zhuyj wrote:
>> >>  +void register_checmate_prog_ops(void);
>> >> maybe it is extern void register_checmate_prog_ops(void);?
>> >>
>> >> +       preempt_disable();
>> >> +       rcu_read_lock();
>> >> IMHO, it is not necessary to use the above 2 since rcu_read_lock will
>> >> call preempt_disable.
>> >
>> > You might double check if this claim is true if CONFIG_PREEMPT_RCU=y
>> >
>> >
>> >
> Thanks for your feedback zhuyj, Looking at kernel documentation itself, it looks
> like this is the preferred mechanism[1]. Their example:
>
>  1 preempt_disable();
>  2 rcu_read_lock();
>  3 do_something();
>  4 rcu_read_unlock();
>  5 preempt_enable();
>
> But, I think you're right. Do you know if there's a great benefit of doing this?
> Or does it make sense to implement a new macro, a la
> rcu_read_lock_and_preent_disable()?
>
> [1] https://www.kernel.org/doc/Documentation/RCU/Design/Requirements/Requirements.html#Disabling Preemption Does Not Block Grace Periods
