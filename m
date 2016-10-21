From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Thu, 20 Oct 2016 17:46:17 -0700
Message-ID: <f0888a5e-e358-8b46-3fe7-581e4811fe72@gmail.com>
References: <20161021092710.1b56a35b@canb.auug.org.au>
 <bd2fa038-2d0a-8cd1-d80d-860a7497bdf5@gmail.com>
 <e2380249-29b4-4769-514a-5fc5fbd8f95c@gmail.com>
 <20161021114334.1eb189aa@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:32879 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753100AbcJUAqU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 20:46:20 -0400
In-Reply-To: <20161021114334.1eb189aa@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/2016 05:43 PM, Stephen Rothwell wrote:
> Hi Florian,
> 
> On Thu, 20 Oct 2016 17:30:33 -0700 Florian Fainelli <f.fainelli@gmail.com> wrote:
>>
>> On 10/20/2016 03:42 PM, Florian Fainelli wrote:
>>> On 10/20/2016 03:27 PM, Stephen Rothwell wrote:  
>>>>
>>>> After merging the net tree, today's linux-next build (arm
>>>> multi_v7_defconfig) failed like this:
>>>>
>>>> ERROR: "kexec_in_progress" [drivers/net/dsa/bcm_sf2.ko] undefined!
>>>>
>>>> Caused by commit
>>>>
>>>>   2399d6143f85 ("net: dsa: bcm_sf2: Prevent GPHY shutdown for kexec'd kernels")
>>>>
>>>> I used the version of the net tree from next-20161020 for today.  
>>>
>>> OK, seems like we need an ifdef CONFIG_KEXEC_CORE, let me fix that.
>>> Thanks Stephen!  
>>
>> Stephen, can you send me the .config file? I could not reproduce it with
>> next-20161020 and doing a make multi_v7_defconfig:
> 
> This only started with the net tree as of today (HEAD a681574c99be).
> The problem is simply that kexec_in_progress is not exported to modules.

Realized that right after sending you the email.

> 
> Sorry, getting the actual .config file is a pain at this point since my
> builds have moved on.
> 
> It probably had (the current .config has):
> 
> CONFIG_NET_DSA_BCM_SF2=m
> CONFIG_KEXEC_CORE=y
> 
> If CONFIG_KEXEC_CORE is not set, then kexec_in_progress is defined to false.

Yes indeed, I have a fix ready, thanks!
-- 
Florian
