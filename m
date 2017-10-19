From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Linux 4.12+ memory leak on router with i40e NICs
Date: Thu, 19 Oct 2017 10:10:10 -0700
Message-ID: <CAKgT0Uf+LZPaQgSzgFuu1_HYxxHLCRckKpx1=eO+WSc_MmNGtg@mail.gmail.com>
References: <1507121766.30720.4.camel@cohaesio.com> <b4995fc8-1420-fe96-26f7-ad5d986b7d39@gmail.com>
 <3d783736-a474-d9e3-2de2-e35c765f8249@itcare.pl> <39696136-2a4a-9c6c-3a63-4485ed2a1bf3@itcare.pl>
 <CAKgT0Uf=0yasidUfyadNSxzkhKvtxH2t83fjb-SU7OaAnrMReA@mail.gmail.com>
 <310ce203-0d65-bdf4-d9e4-897a349b3277@itcare.pl> <f6e2208a-4cdf-3303-5999-92186b437b62@itcare.pl>
 <1704eb26-c4c5-b196-ca7a-5265e92ae4e6@itcare.pl> <bd82f85a-f9b8-a09a-beab-67667b58f36a@itcare.pl>
 <7fd828d7-c586-2c32-3ba6-e0575bf9958c@itcare.pl> <99eba19f-327e-e01f-4f4a-87540b176e40@itcare.pl>
 <efcc51b4-f911-11ec-1c56-fcf31081f9d5@itcare.pl> <d79df7f2-5de4-cc37-baf0-5603f025155e@itcare.pl>
 <748b6d9d-4a3f-4eaa-ad24-27060c2e2642@itcare.pl> <16c9fa34-252f-e5a3-8b15-e5a8c4d8a46f@itcare.pl>
 <12670bc6-439c-7ef4-109a-fd20384b9ca2@itcare.pl> <bd59ccc3-2af4-6842-8d2f-169229a61470@itcare.pl>
 <888ec430-1d70-68e6-2ee8-bab53d21bb0f@itcare.pl> <CAKgT0Ud=GRrsNtoM0gOgzsh1uPJ7nuT9S-xbigmbUMi+iz-ufw@mail.gmail.com>
 <d4d1c562-e976-1894-e36c-709fd319dfb2@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Pavlos Parissis <pavlos.parissis@gmail.com>,
        "Anders K. Pedersen | Cohaesio" <akp@cohaesio.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>
To: =?UTF-8?Q?Pawe=C5=82_Staszewski?= <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:49983 "EHLO
        mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753867AbdJSRKM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 13:10:12 -0400
Received: by mail-qk0-f170.google.com with SMTP id q83so11208810qke.6
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 10:10:12 -0700 (PDT)
In-Reply-To: <d4d1c562-e976-1894-e36c-709fd319dfb2@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 18, 2017 at 4:51 PM, Pawe=C5=82 Staszewski <pstaszewski@itcare.=
pl> wrote:
>
>
> W dniu 2017-10-19 o 01:37, Alexander Duyck pisze:
>
>> On Wed, Oct 18, 2017 at 4:22 PM, Pawe=C5=82 Staszewski <pstaszewski@itca=
re.pl>
>> wrote:
>>>
>>>
>>> W dniu 2017-10-19 o 00:58, Pawe=C5=82 Staszewski pisze:

<snip>

>>> Change rx-usecs 16 tx usecs 16
>>> ifc=3D'enp2s0f0 enp2s0f1 enp2s0f2 enp2s0f3 enp3s0f0 enp3s0f1 enp3s0f2
>>> enp3s0f3'
>>> for i in $ifc
>>>          do
>>>          ip link set up dev $i
>>>          ethtool -A $i autoneg off rx off tx off
>>>          ethtool -G $i rx 2048 tx 2048
>>>          ip link set $i txqueuelen 1000
>>>          ethtool -C $i adaptive-rx off adaptive-tx off rx-usecs 16
>>> tx-usecs
>>> 16
>>>          ethtool -L $i combined 6
>>>          ethtool -K $i ntuple on
>>>          ethtool -K $i gro on
>>>          ethtool -K $i tso on
>>>          done
>>>
>>> MEMLEAK: 0-2MB/s with some recycles
>>> 0  MB/10sec
>>> 0  MB/10sec
>>> 0  MB/10sec
>>> 0  MB/10sec
>>> 0  MB/10sec
>>> 0  MB/10sec
>>> 1  MB/10sec
>>> 0  MB/10sec
>>> 2  MB/10sec
>>> 0  MB/10sec
>>> 2  MB/10sec
>>> -1  MB/10sec
>>> 0  MB/10sec
>>> 2  MB/10sec
>>> 0  MB/10sec
>>> 2  MB/10sec
>>> -1  MB/10sec
>>> 1  MB/10sec
>>
>> This data doesn't tell me much of anything and isn't what I asked for.
>> I don't see how the interrupt throttling rate would be associated with
>> your memory leak other than possibly rate limiting it by rate limiting
>> the traffic itself. Is there something that gave you the impression
>> that interrupt rate was somehow involved?
>
> more interrupts more leak

Right, but this isn't really any new information. More general
activity equals more memory leak, we already knew that.

When debugging, what is useful is to isolate a problem down to a
subset of the original problem. So for example, if you are seeing some
traffic pattern that makes it significantly worse that would be useful
info. Generally instead of trying to find cases that make the issue
less likely to happen anything that you can find that make it more
likely to happen would be useful.

Anything that makes the reproduction easier to get would be useful as
it makes the test for the issue being fixed that much easier since
there should be a start contrast for the driver with the issue versus
the driver without. A fast failure is always much easier to diagnose
than a lingering issue.

>>
>> When we last talked I had asked if you could do a git bisect to find
>> the memory leak and you said you would look into it. The most useful
>> way to solve this would be to do a git bisect between your current
>> kernel and the 4.11 kernel to find the point at which this started. If
>> we can do that then fixing this becomes much simpler as we just have
>> to fix the patch that introduced the issue.
>>
>> Also, I don't know it is you are using to determine that there is a
>> memory leak. What tool is it you are using to do the tracking? Is
>> there any specific form of traffic that is causing the leak? If you
>> can't perform the bisection, any information you could provide that
>> would allow me to do it would also be useful.
>
> simple script
>
> mem1=3D`free -m | grep Mem: | awk '{print $3}'`
> sleep 10
> mem2=3D`free -m | grep Mem: | awk '{print $3}'`
>
> num=3D$((mem2 - mem1))
> echo $num " MB/10sec"
>
>
> There is nothing more that gets mem
> there is only routed traffic from interface A to B
> nothings takes mem
> And memleaks only anchge when i change the rx/tx usecs for card
>
> What You need more ?

No more needed. This tells me what I need to be able to start a
reproduction setup.

> imagine this is not my only prblem but many - i just want to help i chang=
ed
> cards to i40e based only cause somebody rises a bug - and i want to use i=
40e
> in feature - dont need them now - but maybee it is good to help ppl to so=
lwe
> some problems now if i can - before i will use this cards ?

Your attempt to help is appreciated, and I want to solve these issues as we=
ll.

> I try to use i40e before but there was bug covered by bug - and nobody fr=
om
> e1000.sf can help me they just reply after year and closing tickets with
> info about no activity but they have info in reported bugs ... soooo what=
 is
> this ? support center ? for me no .

We don't ask you to be a support center, but we need to have either a
clear problem definition or a willingness to provide more information.
As you stated there are multiple issues with the driver, it isn't
perfect since it is developed by people and people make mistakes. We
need a very clear problem statement and reproduction steps when an
issue is reported so that we can first try to reproduce the issue, and
secondly try to verify that it has been resolved. When the problem
statement is vague, and you aren't willing to test fixes or providing
debugging information there isn't much we can do. As such we are much
more likely to close a bug ticket when we cannot reproduce the issue,
and you are not willing to work with us to test possible fixes for the
issue.

> If i want to help -=3D after a year response will be something like - "do=
nt
> care now" - cause i'v used other hw or sme hacks to repair problem that
> should be sloved by intel

You are welcome to help. This thread started out focusing on the i40e
memory leak issue being reported by Anders, and I would appreciate it
if we could keep this focused on the i40e memory leak. Trying to
hijack the thread to address other issues that may have been reported
on e1000.sf.net, but closed for whatever reason isn't productive. We
need to focus on one issue per thread at a time, just complaining that
something is buggy isn't productive and doesn't solve any issues.

We have your definition for the problem you are seeing. We can work on
trying to reproduce the issue in our environment. Our internal
validation hasn't seen this issue so we likely have some sort of test
escape internally that we need to resolve in our validation
environment.

Anders has said he would be willing to work with us on getting a
bisection. That will help significantly for us to try to get to a root
cause for this issue. In addition once we have the root cause we can
also start sorting out why we didn't catch this in our own validation.

Your help on this issue has been appreciated, but if you aren't
willing to perform a bisection then there isn't any more we need from
you at this time. We will work internally and with Anders to get the
bisection data we need. We have no further need of information on the
issue at this time as we need to focus on test reproduction, and
determining the change that introduced this issue.

Thanks.

- Alex
