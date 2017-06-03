From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH 7/7] mlx5: Do not build eswitch_offloads if
 CONFIG_MLX5_EN_ESWITCH_OFFLOADS is set
Date: Sat, 3 Jun 2017 22:37:01 +0300
Message-ID: <CAJ3xEMhKjPwg75hO8af7XDL5JPoxkq2AtpL61CtOLb-T4aACWQ@mail.gmail.com>
References: <20170526211624.23133-1-jsorensen@fb.com> <20170526211624.23133-8-jsorensen@fb.com>
 <CAJ3xEMgeBaE9q6sucXtOQTBLAvZvf_d0eGvMsGbVa2vWc21R-Q@mail.gmail.com>
 <e7c36f4e-788a-89dd-e92e-e6a31004758a@gmail.com> <CAJ3xEMh8ALo9Pgb0sh5dzAFaPtiKDaZyEhgasgi40Pba1JzCQA@mail.gmail.com>
 <c5b3bd3d-b5de-8b0b-34ff-068a1b3bd31c@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jes Sorensen <jes.sorensen@gmail.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Ilan Tayari <ilant@mellanox.com>
To: Jes Sorensen <jsorensen@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:34764 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750991AbdFCThD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Jun 2017 15:37:03 -0400
Received: by mail-oi0-f66.google.com with SMTP id d99so4973805oic.1
        for <netdev@vger.kernel.org>; Sat, 03 Jun 2017 12:37:02 -0700 (PDT)
In-Reply-To: <c5b3bd3d-b5de-8b0b-34ff-068a1b3bd31c@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 2, 2017 at 11:22 PM, Jes Sorensen <jsorensen@fb.com> wrote:
> On 05/28/2017 02:03 AM, Or Gerlitz wrote:
>>
>> On Sun, May 28, 2017 at 5:23 AM, Jes Sorensen <jes.sorensen@gmail.com>
>> wrote:
>>>
>>> On 05/27/2017 05:02 PM, Or Gerlitz wrote:
>>>>
>>>>
>>>> On Sat, May 27, 2017 at 12:16 AM, Jes Sorensen <jes.sorensen@gmail.com>
>>>> wrote:
>>>>>
>>>>>
>>>>> This gets rid of the temporary #ifdef spaghetti and allows the code to
>>>>> compile without offload support enabled.
>>
>>
>>>> I am pretty sure we can do that exercise you're up to without any
>>>> spaghetti cooking and even put more code under that CONFIG directive
>>>> (en_rep.c), I'll take that with Saeed.
>>
>>
>>> I want to avoid adding #ifdef CONFIG_foo to the main code in order to
>>> keep
>>> it readable. I did it gradually to make sure I didn't break anything and
>>> to
>>> allow for it to be bisected in case something did break. If we can move
>>> out
>>> more code from places like en_rep.c into eswitch_offload.c and get it
>>> disabled that way that would be great, but I like to limit the number of
>>> #ifdefs we add to the actual code.
>>
>>
>> FWIW (see below), squashing your seven patches to one resulted in a
>> fairly simple/clear
>> patch, so if we go that way, no need to have seven commits just for this
>> piece.
>
>
> Squashing patches into jumbo patches is inherently broken and bad coding
> practice! It makes it way more complicated to debug and bisect in case a
> minor detail broke in the process.

Not that pure LOC ##-s is the only/deep measurement, but your overall
changes in the the seven patch series account to:

 5 files changed, 94 insertions(+), 3 deletions(-)

and by no mean this is jumbo or inherently broken and bad coded, so
please slow down please, I looked with care on the resulted patch and
said it's basically ok.


>> Re SRIOV, I don't think it would be correct to break the support info few
>> CONFIG directives. If we want to allow someone to build the driver w.o
>> SRIOV that's fine, but I don't think we should further go down and disable
>> some of the SRIOV sub-modes.

>> Re TC offload support, that's make sense.

> OK, so disabling SRIOV and disabling TC makes sense - I'll look at that.

I think Saeed wants us to conduct that exercise, let me check with him
and get back to you
