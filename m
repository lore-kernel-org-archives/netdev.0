From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH 7/7] mlx5: Do not build eswitch_offloads if
 CONFIG_MLX5_EN_ESWITCH_OFFLOADS is set
Date: Sun, 28 May 2017 09:03:19 +0300
Message-ID: <CAJ3xEMh8ALo9Pgb0sh5dzAFaPtiKDaZyEhgasgi40Pba1JzCQA@mail.gmail.com>
References: <20170526211624.23133-1-jsorensen@fb.com> <20170526211624.23133-8-jsorensen@fb.com>
 <CAJ3xEMgeBaE9q6sucXtOQTBLAvZvf_d0eGvMsGbVa2vWc21R-Q@mail.gmail.com> <e7c36f4e-788a-89dd-e92e-e6a31004758a@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Ilan Tayari <ilant@mellanox.com>,
        Jes Sorensen <jsorensen@fb.com>
To: Jes Sorensen <jes.sorensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:35093 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750913AbdE1GDU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 May 2017 02:03:20 -0400
Received: by mail-oi0-f67.google.com with SMTP id v80so7425250oie.2
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 23:03:20 -0700 (PDT)
In-Reply-To: <e7c36f4e-788a-89dd-e92e-e6a31004758a@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 28, 2017 at 5:23 AM, Jes Sorensen <jes.sorensen@gmail.com> wrote:
> On 05/27/2017 05:02 PM, Or Gerlitz wrote:
>>
>> On Sat, May 27, 2017 at 12:16 AM, Jes Sorensen <jes.sorensen@gmail.com>
>> wrote:
>>>
>>> This gets rid of the temporary #ifdef spaghetti and allows the code to
>>> compile without offload support enabled.

>> I am pretty sure we can do that exercise you're up to without any
>> spaghetti cooking and even put more code under that CONFIG directive
>> (en_rep.c), I'll take that with Saeed.

> I want to avoid adding #ifdef CONFIG_foo to the main code in order to keep
> it readable. I did it gradually to make sure I didn't break anything and to
> allow for it to be bisected in case something did break. If we can move out
> more code from places like en_rep.c into eswitch_offload.c and get it
> disabled that way that would be great, but I like to limit the number of
> #ifdefs we add to the actual code.

FWIW (see below), squashing your seven patches to one resulted in a
fairly simple/clear
patch, so if we go that way, no need to have seven commits just for this piece.

>> Just wondering, you are motivated by a wish to put some mlx5
>> functionalities under their own CONFIG directives which could be
>> useful when backporting the latest upstream driver into older kernel
>> and being able not to deal with parts of it, right? in that respect,
>> are you using SRIOV but not the offloads mode?

> The motivation is two-fold, the primary is to be able to disable features
> not being used for those who compile a custom kernel and who wish to reduce
> the codebase compiled. It also makes it more flexible when back porting the
> code to older kernels since it is easier to pick out a smaller subset. I was
> going to look into making TC support etc. optional next, but I wanted to
> have a discussion about this patchset first.

OKay, I got you.

Re SRIOV, I don't think it would be correct to break the support info few
CONFIG directives. If we want to allow someone to build the driver w.o
SRIOV that's fine, but I don't think we should further go down and disable
some of the SRIOV sub-modes.

Re TC offload support, that's make sense.

Or.
