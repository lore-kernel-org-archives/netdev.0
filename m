From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v2 1/1] eventfd: implementation of EFD_MASK flag
Date: Thu, 14 Feb 2013 15:57:59 -0800
Message-ID: <CALCETrXG0pj6ZCCK5OJ3iTRPW4EGM=szNX+iR0wJ5kaq0mHJWg@mail.gmail.com>
References: <1360311077-14474-1-git-send-email-sustrik@250bpm.com> <20130214145430.04f8750c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Martin Sustrik <sustrik@250bpm.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Sha Zhengju <handai.szj@taobao.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>,
	Davide Libenzi <davidel@xmailserver.org>,
	Eric Wong <normalperson@yhbt.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130214145430.04f8750c.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 14, 2013 at 2:54 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Fri,  8 Feb 2013 09:11:17 +0100
> Martin Sustrik <sustrik@250bpm.com> wrote:
>
>> When implementing network protocols in user space, one has to implement
>> fake user-space file descriptors to represent the sockets for the protocol.

>
>>       if (count < sizeof(ucnt))
>>               return -EINVAL;
>> @@ -293,8 +351,13 @@ static int eventfd_show_fdinfo(struct seq_file *m, struct file *f)
>>       int ret;
>>
>>       spin_lock_irq(&ctx->wqh.lock);
>> -     ret = seq_printf(m, "eventfd-count: %16llx\n",
>> -                      (unsigned long long)ctx->count);
>> +     if (ctx->flags & EFD_MASK) {
>> +             ret = seq_printf(m, "eventfd-mask: %x\n",
>> +                              (unsigned)ctx->mask.events);
>> +     } else {
>> +             ret = seq_printf(m, "eventfd-count: %16llx\n",
>> +                              (unsigned long long)ctx->count);
>> +     }
>>       spin_unlock_irq(&ctx->wqh.lock);
>
> This is a non-back-compatible userspace interface change.  A procfs
> file which previously displayed
>
>         eventfd-count: nnnn
>
> can now also display
>
>         eventfd-mask: nnnn
>
> So existing userspace could misbehave.
>
> Please fully describe the proposed interface change in the changelog.
> That description should include the full pathname of the procfs file
> and example before-and-after output and a discussion of whether and why
> the risk to existing userspace is acceptable.

I suspect that the fdinfo stuff is only used by criu, which will need
to be updated regardless.  (If the kernel adopts the policy "don't
break criu", then that may be the end of new kernel features.)

--Andy
