From: Jes Sorensen <jsorensen@fb.com>
Subject: Re: [PATCH 7/7] mlx5: Do not build eswitch_offloads if
 CONFIG_MLX5_EN_ESWITCH_OFFLOADS is set
Date: Tue, 6 Jun 2017 17:46:05 -0400
Message-ID: <34ee6c6c-e509-40d0-77f7-a5ac451139a7@fb.com>
References: <20170526211624.23133-1-jsorensen@fb.com>
 <20170526211624.23133-8-jsorensen@fb.com>
 <CAJ3xEMgeBaE9q6sucXtOQTBLAvZvf_d0eGvMsGbVa2vWc21R-Q@mail.gmail.com>
 <e7c36f4e-788a-89dd-e92e-e6a31004758a@gmail.com>
 <CAJ3xEMh8ALo9Pgb0sh5dzAFaPtiKDaZyEhgasgi40Pba1JzCQA@mail.gmail.com>
 <c5b3bd3d-b5de-8b0b-34ff-068a1b3bd31c@fb.com>
 <CAJ3xEMhKjPwg75hO8af7XDL5JPoxkq2AtpL61CtOLb-T4aACWQ@mail.gmail.com>
 <aed5b35a-3467-7e01-6f14-e70ea4a94832@fb.com>
 <CALzJLG-=WU8DFNkqjAKBSFjHyc1V2YvoWV4r7fG9QVSRTybgZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
        Jes Sorensen <jes.sorensen@gmail.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Ilan Tayari <ilant@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:51016 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751436AbdFFVqZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 17:46:25 -0400
In-Reply-To: <CALzJLG-=WU8DFNkqjAKBSFjHyc1V2YvoWV4r7fG9QVSRTybgZw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/05/2017 05:53 PM, Saeed Mahameed wrote:
> On Mon, Jun 5, 2017 at 11:51 PM, Jes Sorensen <jsorensen@fb.com> wrote:
>> On 06/03/2017 03:37 PM, Or Gerlitz wrote:
>>>
>>> On Fri, Jun 2, 2017 at 11:22 PM, Jes Sorensen <jsorensen@fb.com> wrote:
>>>>
>>>> On 05/28/2017 02:03 AM, Or Gerlitz wrote:
>>>>>
>>>>>
>>>>> On Sun, May 28, 2017 at 5:23 AM, Jes Sorensen <jes.sorensen@gmail.com>
>>>>> wrote:
>>>>>>
>>>>>>
>>>>>> On 05/27/2017 05:02 PM, Or Gerlitz wrote:
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>> On Sat, May 27, 2017 at 12:16 AM, Jes Sorensen
>>>>>>> <jes.sorensen@gmail.com>
>>>>>>> wrote:
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>> This gets rid of the temporary #ifdef spaghetti and allows the code
>>>>>>>> to
>>>>>>>> compile without offload support enabled.
>>>>>
>>>>>
>>>>>
>>>>>>> I am pretty sure we can do that exercise you're up to without any
>>>>>>> spaghetti cooking and even put more code under that CONFIG directive
>>>>>>> (en_rep.c), I'll take that with Saeed.
>>>>>
>>>>>
>>>>>
>>>>>> I want to avoid adding #ifdef CONFIG_foo to the main code in order to
>>>>>> keep
>>>>>> it readable. I did it gradually to make sure I didn't break anything
>>>>>> and
>>>>>> to
>>>>>> allow for it to be bisected in case something did break. If we can move
>>>>>> out
>>>>>> more code from places like en_rep.c into eswitch_offload.c and get it
>>>>>> disabled that way that would be great, but I like to limit the number
>>>>>> of
>>>>>> #ifdefs we add to the actual code.
>>>>>
>>>>>
>>>>>
>>>>> FWIW (see below), squashing your seven patches to one resulted in a
>>>>> fairly simple/clear
>>>>> patch, so if we go that way, no need to have seven commits just for this
>>>>> piece.
>>>>
>>>>
>>>>
>>>> Squashing patches into jumbo patches is inherently broken and bad coding
>>>> practice! It makes it way more complicated to debug and bisect in case a
>>>> minor detail broke in the process.
>>>
>>>
>>> Not that pure LOC ##-s is the only/deep measurement, but your overall
>>> changes in the the seven patch series account to:
>>>
>>>    5 files changed, 94 insertions(+), 3 deletions(-)
>>>
>>> and by no mean this is jumbo or inherently broken and bad coded, so
>>> please slow down please, I looked with care on the resulted patch and
>>> said it's basically ok.
>>
>>
>> Squashing patches for the sake of squashing patches is inherently broken and
>> bad. So please calm down and stop this mangling of other peoples' patches.
>>
>> If you want an alternative, put up a proposal and look at it for comparison
>> somewhere.
>
> Hey Jes,
> 
> It is not just about squashing patches, I am working on a series of
> patches to allow compiling out eswitch/eswitch_offloads/en_rep.c/en_tc
> altogether, it will come out cleaner as it will remove all ethernet
> sriov/eswitch VF representors and eswitch tc offloads stuff with one
> kconfig flag, and yet preserve standard QoS functionality from en_tc.

Saeed,

I realize it is not just about squashing patches, however doing that to 
someone else's patches is just broken. The Linux kernel way is to build 
on top of patches, if they are valid, rather than throwing them all away 
and doing it from scratch again bottom up. If there was something 
actually wrong with my patches, and I would love to understand if that 
is the case, since I don't know 1/100th of the hardware details that you 
know, then please share those details.

> BTW today you can just remove eswitch from driver and non sriov
> configuration will perfectly work with no issues.
> Even multi PF configuration will also work, but without l2 mac table,
> which means PFs can only see packets with their own static (permanent)
> mac addresses, user configured macs will not work on Multi PF
> configuration.

It sounds like this shakes up things a little and we will have things 
moved to where they actually belong in the hierarchy so that will be a 
good thing in the end :)

> For that i will take the l2 table (ConnectX PF mac table) logic out of
> eswitch as it is not really an eswitch logic, and move it to core
> driver to allow Multi PF configuration to work without eswitch.

Sounds good.

> I will post some patches for you to review by end of week.

Could we please start seeing this stuff happen in a public git tree so 
it is possible to follow and contribute to the development? It is very 
frustrating having to wait for things to appear and and not knowing 
whether a patch is integrated or needs to be revised when you have 
things building on top of it.

Jes
