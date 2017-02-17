From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [BUG] 4.10-rc8 - ping spinning?
Date: Thu, 16 Feb 2017 23:21:06 -0500
Message-ID: <CACSApvasp5Z-YUnALSDmXqS5o2gWDo6QPXg9m35HEx8-+m1rug@mail.gmail.com>
References: <20170216120547.GK582@shells.gnugeneration.com>
 <CACSApvYq-7HGAO+UTsoCu6JVt_E4mdXKgpUbRD0YDP_M02ZdkQ@mail.gmail.com>
 <CACSApvYbP9peXPm2L4EFJokdXbGV7bTLgZNOEKEiHjLWcOOZHA@mail.gmail.com> <20170216160806.GL582@shells.gnugeneration.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: lkml@pengaru.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170216160806.GL582@shells.gnugeneration.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 16, 2017 at 11:08 AM,  <lkml@pengaru.com> wrote:
> On Thu, Feb 16, 2017 at 10:52:19AM -0500, Soheil Hassas Yeganeh wrote:
>> On Thu, Feb 16, 2017 at 10:50 AM, Soheil Hassas Yeganeh
>> <soheil@google.com> wrote:
>> > Thank you Vito for the report.
>> >
>> > The patch you cited actually resolves a similar backward compatibility
>> > problem for traceroute.
>> >
>> > I suspect the problem here is that there's a local error queued on the
>> > error queue after an ICMP message. ping apparently expect the
>> > sk->sk_err to be set for the local errors as well, and hence the
>> > error. Ideally, ping should read the error queue if there an EPOLLERR,
>> > because local errors never sk->sk_err on their own. That is, if we
>> > have
>>
>> [oops] That is, if we have only one local error on the error queue, we
>> cannot rely on having an error on recvmsg (i.e., sk->sk_err being set)
>> even in 4.9.
>>
>> <snip>
>
> Hi Soheil,
>
> This doesn't appear to be trivially reproducible here by just running ping
> as it were originally discovered.  I'll see if I can reliably cause the
> malfunction somehow, but until then I can't meaningfully test patches.
>
> Perhaps a form of fault injection would make more sense if there's a
> reasonable idea of what this is stemming from?

I tried to generate different ICMP errors as well as local errors, but
unfortunately haven't been able to reproduce the problem.

> I've opened an issue with iputils on github in the event that this is found
> to be a ping bug.  Your input might be helpful there as well:
> https://github.com/iputils/iputils/issues/74

Sent a pull request. Although, we might want to at least confirm the
userspace patch fixes the issue in ping.

Thanks!
Soheil

> Thanks,
> Vito Caputo
