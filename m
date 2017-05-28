From: Jes Sorensen <jes.sorensen@gmail.com>
Subject: Re: [PATCH 7/7] mlx5: Do not build eswitch_offloads if
 CONFIG_MLX5_EN_ESWITCH_OFFLOADS is set
Date: Sat, 27 May 2017 22:23:58 -0400
Message-ID: <e7c36f4e-788a-89dd-e92e-e6a31004758a@gmail.com>
References: <20170526211624.23133-1-jsorensen@fb.com>
 <20170526211624.23133-8-jsorensen@fb.com>
 <CAJ3xEMgeBaE9q6sucXtOQTBLAvZvf_d0eGvMsGbVa2vWc21R-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Ilan Tayari <ilant@mellanox.com>,
        Jes Sorensen <jsorensen@fb.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:35154 "EHLO
        mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750762AbdE1CYH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 22:24:07 -0400
Received: by mail-yw0-f193.google.com with SMTP id p144so2735042ywp.2
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 19:24:07 -0700 (PDT)
In-Reply-To: <CAJ3xEMgeBaE9q6sucXtOQTBLAvZvf_d0eGvMsGbVa2vWc21R-Q@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/27/2017 05:02 PM, Or Gerlitz wrote:
> On Sat, May 27, 2017 at 12:16 AM, Jes Sorensen <jes.sorensen@gmail.com> wrote:
>> This gets rid of the temporary #ifdef spaghetti and allows the code to
>> compile without offload support enabled.
> 
> Hi Jes,
> 
> I am pretty sure we can do that exercise you're up to without any
> spaghetti cooking and even put more code under that CONFIG directive
> (en_rep.c), I'll take that with Saeed.

Hi Or,

I want to avoid adding #ifdef CONFIG_foo to the main code in order to 
keep it readable. I did it gradually to make sure I didn't break 
anything and to allow for it to be bisected in case something did break. 
If we can move out more code from places like en_rep.c into 
eswitch_offload.c and get it disabled that way that would be great, but 
I like to limit the number of #ifdefs we add to the actual code.

> Just wondering, you are motivated by a wish to put some mlx5
> functionalities under their own CONFIG directives which could be
> useful when backporting the latest upstream driver into older kernel
> and being able not to deal with parts of it, right? in that respect,
> are you using SRIOV but not the offloads mode?

The motivation is two-fold, the primary is to be able to disable 
features not being used for those who compile a custom kernel and who 
wish to reduce the codebase compiled. It also makes it more flexible 
when back porting the code to older kernels since it is easier to pick 
out a smaller subset. I was going to look into making TC support etc. 
optional next, but I wanted to have a discussion about this patchset first.

Cheers,
Jes
