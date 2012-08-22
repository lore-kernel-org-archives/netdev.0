From: Francesco Ruggeri <fruggeri@aristanetworks.com>
Subject: Re: [PATCH 1/1] ipv4: ipmr_expire_timer causes crash when removing
 net namespace
Date: Wed, 22 Aug 2012 15:56:16 -0700
Message-ID: <CA+HUmGicUy3hLvTwtBe5jj98GC=irAsEJtAfsVQAtppdRp7ijg@mail.gmail.com>
References: <CA+HUmGgAx-APi4DRr=M2nUMfiO8yjcxovvqkTuX7=ZpUDbo5Tg@mail.gmail.com>
	<1345526991.5158.373.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:63223 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755856Ab2HVW4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 18:56:17 -0400
Received: by obbuo13 with SMTP id uo13so318366obb.19
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 15:56:17 -0700 (PDT)
In-Reply-To: <1345526991.5158.373.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 20, 2012 at 10:29 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2012-08-20 at 17:15 -0700, Francesco Ruggeri wrote:
>> I
>> +static void ipmr_free_table(struct mr_table *mrt)
>> +{
>> +     del_timer(&mrt->ipmr_expire_timer);
>> +     mroute_clean_tables(mrt);
>> +     kfree(mrt);
>> +}
>
> Seems racy to me.
>
> del_timer() doesnt make sure timer is completely disabled.
>
> Probably need spin_lock_bh(&mfc_unres_lock) /
> spin_unlock_bh(&mfc_unres_lock), and maybe del_timer_sync()
>

I see your point, del_timer_sync should be used to take care of any
pending timers.
I am not sure about the need for further locking though. This function
simply replaces a direct call to kfree(mrt), so I assume by this point
today's code already makes sure no one is going to access this
structure (including to start the timer), or we have a bigger problem
than just the timer.
Maybe someone familiar with ipmr can comment.

Francesco

>
>
