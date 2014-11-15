From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next] net: introduce SO_INCOMING_CPU
Date: Sat, 15 Nov 2014 10:41:41 -0800
Message-ID: <CA+mtBx-=fbA+pW35K8cjXTJpw30jhawy1mhs-MDEYv9SCyD2MQ@mail.gmail.com>
References: <1415393472.13896.119.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHO5Pa0OGtgbUp4R287jbK2SFSpVUoXWCJybvHTFsGyCLynqLg@mail.gmail.com>
	<CALCETrXmCWSoeQLC3WCqMf_sehGVE9KTbTGmsA77ZN84B-V24Q@mail.gmail.com>
	<1415993614.17262.55.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+mtBx_DyUCxE6BqL_xXcqKPUDu7b3jLShV+AL6L+gCzJLriPg@mail.gmail.com>
	<CALCETrUuChgxXcNrKjYzpe1ry0hx3kf19EfAbY1N1YnG7NFZUw@mail.gmail.com>
	<CA+mtBx_tNW_Bz0hovZ90XxcLK6pL8d6RX=v5Rg8utfKkaFoJ+Q@mail.gmail.com>
	<CALCETrWYrR2X9u7CAr5xkSg8kLH_O=sdk=JF+ZW+FxCTNTFBZg@mail.gmail.com>
	<CA+mtBx9dSNOD5Z8GinU8F1mj_PgU0sTC5g8S9vRuSnSUzAoD=g@mail.gmail.com>
	<CALCETrXf8j52nmpw-A2+bQt0yoz-fiD-4GP4Qf-afwH6UjCVnw@mail.gmail.com>
	<CA+mtBx9Z33O0x4-MG=66Fb4qvBJfxV54xOyiYvWydr=4Bka2xw@mail.gmail.com>
	<CALCETrXnM5zCt651QWF0Z3c197gqzbLA29bQzwi64DnCvS48NQ@mail.gmail.com>
	<CA+mtBx8uneXRoc5HcXED58zi44UyMZGJS6_sU3av8ST1ft7Diw@mail.gmail.com>
	<CALCETrU5Og8tfkFuA-rPY5evV5CkPsx=22f6mePHJPvfcRrBdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Ying Cai <ycai@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Linux API <linux-api@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:38768 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754273AbaKOSln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Nov 2014 13:41:43 -0500
Received: by mail-ie0-f176.google.com with SMTP id rd18so19099219iec.7
        for <netdev@vger.kernel.org>; Sat, 15 Nov 2014 10:41:42 -0800 (PST)
In-Reply-To: <CALCETrU5Og8tfkFuA-rPY5evV5CkPsx=22f6mePHJPvfcRrBdA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 14, 2014 at 4:50 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Fri, Nov 14, 2014 at 4:40 PM, Tom Herbert <therbert@google.com> wrote:
>> On Fri, Nov 14, 2014 at 4:24 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>>> On Fri, Nov 14, 2014 at 4:06 PM, Tom Herbert <therbert@google.com> wrote:
>>>> On Fri, Nov 14, 2014 at 2:10 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>>>>> On Fri, Nov 14, 2014 at 1:36 PM, Tom Herbert <therbert@google.com> wrote:
>>>>>> On Fri, Nov 14, 2014 at 12:34 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>>>>>>> On Fri, Nov 14, 2014 at 12:25 PM, Tom Herbert <therbert@google.com> wrote:
>>>>>>>> On Fri, Nov 14, 2014 at 12:16 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>>>>>>>>> On Fri, Nov 14, 2014 at 11:52 AM, Tom Herbert <therbert@google.com> wrote:
>>>>>>>>>> On Fri, Nov 14, 2014 at 11:33 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>>>>>>>>>> On Fri, 2014-11-14 at 09:17 -0800, Andy Lutomirski wrote:
>>>>>>>>>>>
>>>>>>>>>>>> As a heavy user of RFS (and finder of bugs in it, too), here's my
>>>>>>>>>>>> question about this API:
>>>>>>>>>>>>
>>>>>>>>>>>> How does an application tell whether the socket represents a
>>>>>>>>>>>> non-actively-steered flow?  If the flow is subject to RFS, then moving
>>>>>>>>>>>> the application handling to the socket's CPU seems problematic, as the
>>>>>>>>>>>> socket's CPU might move as well.  The current implementation in this
>>>>>>>>>>>> patch seems to tell me which CPU the most recent packet came in on,
>>>>>>>>>>>> which is not necessarily very useful.
>>>>>>>>>>>
>>>>>>>>>>> Its the cpu that hit the TCP stack, bringing dozens of cache lines in
>>>>>>>>>>> its cache. This is all that matters,
>>>>>>>>>>>
>>>>>>>>>>>>
>>>>>>>>>>>> Some possibilities:
>>>>>>>>>>>>
>>>>>>>>>>>> 1. Let SO_INCOMING_CPU fail if RFS or RPS are in play.
>>>>>>>>>>>
>>>>>>>>>>> Well, idea is to not use RFS at all. Otherwise, it is useless.
>>>>>>>>>
>>>>>>>>> Sure, but how do I know that it'll be the same CPU next time?
>>>>>>>>>
>>>>>>>>>>>
>>>>>>>>>> Bear in mind this is only an interface to report RX CPU and in itself
>>>>>>>>>> doesn't provide any functionality for changing scheduling, there is
>>>>>>>>>> obviously logic needed in user space that would need to do something.
>>>>>>>>>>
>>>>>>>>>> If we track the interrupting CPU in skb, the interface could be easily
>>>>>>>>>> extended to provide the interrupting CPU, the RPS CPU (calculated at
>>>>>>>>>> reported time), and the CPU processing transport (post steering which
>>>>>>>>>> is what is currently returned). That would provide the complete
>>>>>>>>>> picture to control scheduling a flow from userspace, and an interface
>>>>>>>>>> to selectively turn off RFS for a socket would make sense then.
>>>>>>>>>
>>>>>>>>> I think that a turn-off-RFS interface would also want a way to figure
>>>>>>>>> out where the flow would go without RFS.  Can the network stack do
>>>>>>>>> that (e.g. evaluate the rx indirection hash or whatever happens these
>>>>>>>>> days)?
>>>>>>>>>
>>>>>>>> Yes,. We need the rxhash and the CPU that packets are received on from
>>>>>>>> the device for the socket. The former we already have, the latter
>>>>>>>> might be done by adding a field to skbuff to set received CPU. Given
>>>>>>>> the L4 hash and interrupting CPU we can calculated the RPS CPU which
>>>>>>>> is where packet would have landed with RFS off.
>>>>>>>
>>>>>>> Hmm.  I think this would be useful for me.  It would *definitely* be
>>>>>>> useful for me if I could pin an RFS flow to a cpu of my choice.
>>>>>>>
>>>>>> Andy, can you elaborate a little more on your use case. I've thought
>>>>>> several times about an interface to program the flow table from
>>>>>> userspace, but never quite came up with a compelling use case and
>>>>>> there is the security concern that a user could "steal" cycles from
>>>>>> arbitrary CPUs.
>>>>>
>>>>> I have a bunch of threads that are pinned to various CPUs or groups of
>>>>> CPUs.  Each thread is responsible for a fixed set of flows.  I'd like
>>>>> those flows to go to those CPUs.
>>>>>
>>>>> RFS will eventually do it, but it would be nice if I could
>>>>> deterministically ask for a flow to be routed to the right CPU.  Also,
>>>>> if my thread bounces temporarily to another CPU, I don't really need
>>>>> the flow to follow it -- I'd like it to stay put.
>>>>>
>>>> Okay, how about it we have a SO_RFS_LOCK_FLOW sockopt. When this is
>>>> called on a socket we can lock the socket to CPU binding to the
>>>> current CPU it is called from. It could be unlocked at a later point.
>>>> Would this satisfy your requirements?
>>>
>>> Yes, I think.  Especially if it bypassed the hash table.
>>
>> Unfortunately we can't easily bypass the hash table. The only way I
>> know of to to do that is to perform the socket lookup to do steering
>> (I tried that early on, but it was pretty costly).
>
> What happens if you just call ndo_rx_flow_steer and do something to
> keep the result from expiring?
>
Okay, I will look at that. Do you know how many flows we are talking
about, both in the number you need and the number that can be put in
the HW without collision?

Thanks,
Tom

>>>
>>>> As I mentioned, there is no material functionality in this patch and
>>>> it should be independent of RFS. It simply returns the CPU where the
>>>> stack processed the packet. Whether or not this is meaningful
>>>> information to the algorithm being implemented in userspace is
>>>> completely up to the caller to decide.
>>>
>>> Agreed.
>>>
>>> My only concern is that writing that userspace algorithm might result
>>> in surprises if RFS is on.  Having the user program notice the problem
>>> early and alert the admin might help keep Murphy's Law at bay here.
>>>
>> By Murphy's law we'd also have to consider that the flow hash could
>> change after reading the results so that the scheduling done in
>> userspace is completely wrong until the CPU is read again.
>> Synchronizing kernel and device state with userspace state is not
>> always so easy. One way to mitigate is to use ancillary data which
>> would provide real time information and obviate the need for another
>> system call.
>
> Hmm.  That would work, too.  I don't know how annoyed user code would
> be at having to read ancillary data, though.
>
> The flow hash really shouldn't change much, though, right?
>
> --Andy
