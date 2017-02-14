From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net/xfrm: stack out-of-bounds in xfrm_flowi_sport
Date: Tue, 14 Feb 2017 10:16:44 +0100
Message-ID: <CACT4Y+a7-TXY2f14Cn0wUapiJ5BYv=2wkJ4vcMGMnbDjqTPnVw@mail.gmail.com>
References: <CACT4Y+ZBY+gYUJ9NuxPByEbbrR7M09vBd5Lx4=xGSGXSxai==Q@mail.gmail.com>
 <20170214070854.GH30338@gauss.secunet.com> <CACT4Y+aPd8drh7MQf8cXLs_9f-oymf6YiWfN+owUsSYYz0yMzA@mail.gmail.com>
 <20170214090816.GJ30338@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170214090816.GJ30338@gauss.secunet.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 14, 2017 at 10:08 AM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> On Tue, Feb 14, 2017 at 09:41:35AM +0100, Dmitry Vyukov wrote:
>> On Tue, Feb 14, 2017 at 8:08 AM, Steffen Klassert
>> <steffen.klassert@secunet.com> wrote:
>> > On Mon, Feb 13, 2017 at 03:46:56PM +0100, Dmitry Vyukov wrote:
>> >>
>> >> On commit 7089db84e356562f8ba737c29e472cc42d530dbc.
>> >>
>> >>
>> >> struct flowi4 fl4_stack allocated on stack in udp_sendmsg is being
>> >> casted to larger struct flowi and then accessed.
>> >
>> > Looks like the problem is when using IPv4-mapped IPv6 addresses.
>> >
>> > Does the patch below help?
>>
>>
>> Steffen, can you please run the reproducer I provided?
>> I specifically spent time to supply you with a simple, reliable
>> reproducer. I am not even saying about adding a test case for the bug.
>> Kernel development practices seem to encourage developers to not
>> bother with tests. But at least testing a patch that you are sending
>> looks like a reasonable thing to do.
>
> I tested this with my socket policy testcases of course.
> I dont have a IPv4-mapped IPv6 addresses testcase and
> changing userspace in my test setup means to rebuild
> the system iso image.
>
> Asking for a test is not so uncommon. You have the
> testcase, why not running it again?


Because there are too many kernel subsystems and bugs. I need more
than 24h per day to reports and retest them.

I've run the repro with you patch and don't see the bug any more:

Tested-by: Dmitry Vyukov <dvyukov@google.com>
