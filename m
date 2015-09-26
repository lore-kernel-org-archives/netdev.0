From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: Glibc recvmsg from kernel netlink socket hangs forever
Date: Fri, 25 Sep 2015 19:58:43 -0700
Message-ID: <560609E3.4070307@roeck-us.net>
References: <C3C03EFC-53E1-45DE-87AF-59C7367BD21E@gmail.com>
 <20150925043653.GA29111@roeck-us.net>
 <20150925045853.GA5286@gondor.apana.org.au> <5604DCD2.4090600@roeck-us.net>
 <38FEC418-9C09-47BC-A9FC-5F1EA28941FC@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	netdev@vger.kernel.org
To: Steven Schlansker <stevenschlansker@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <38FEC418-9C09-47BC-A9FC-5F1EA28941FC@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/25/2015 02:37 PM, Steven Schlansker wrote:
>
> On Sep 24, 2015, at 10:34 PM, Guenter Roeck <linux@roeck-us.net> wrote:
>
>> Herbert,
>>
>> On 09/24/2015 09:58 PM, Herbert Xu wrote:
>>> On Thu, Sep 24, 2015 at 09:36:53PM -0700, Guenter Roeck wrote:
>>>>
>>>> http://comments.gmane.org/gmane.linux.network/363085
>>>>
>>>> might explain your problem.
>>>>
>>>> I thought this was resolved in 4.1, but it looks like the problem still persists
>>>> there. At least I have reports from my workplace that 4.1.6 and 4.1.7 are still
>>>> affected. I don't know if there have been any relevant changes in 4.2.
>>>>
>>>> Copying Herbert and Eric for additional input.
>>>
>>> There was a separate bug discovered by Tejun recently.  You need
>>> to apply the patches
>>>
>>> https://patchwork.ozlabs.org/patch/519245/
>>> https://patchwork.ozlabs.org/patch/520824/
>>>
>> I assume this is on top of mainline ?
>>
>>> There is another follow-up but it shouldn't make any difference
>>> in practice.
>>>
>>
>> Any idea what may be needed for 4.1 ?
>> I am currently trying https://patchwork.ozlabs.org/patch/473041/,
>> but I have no idea if that will help with the problem we are seeing there.
>
> Thank you for the patches to try, I'll build a kernel with them early next week
> and report back.  It sounds like it may not match my problem exactly so we'll
> see.
>
> In the meantime, I also observed the following oops:
>
> [ 1709.620092] kernel tried to execute NX-protected page - exploit attempt? (uid: 0)
> [ 1709.624058] BUG: unable to handle kernel paging request at ffffea001dbef3c0
> [ 1709.624058] IP: [<ffffea001dbef3c0>] 0xffffea001dbef3c0
> [ 1709.624058] PGD 78f7dc067 PUD 78f7db067 PMD 800000078ec001e3
> [ 1709.624058] Oops: 0011 [#1] SMP
> [ 1709.624058] Modules linked in: i2c_piix4(E) btrfs(E) crct10dif_pclmul(E) crc32_pclmul(E) ghash_clmulni_intel(E) aesni_intel(E) aes_x86_64(E) lrw(E) gf128mul(E) glue_helper(E) ablk_helper(E) cryptd(E) floppy(E)
> [ 1709.624058] CPU: 4 PID: 19714 Comm: pf_dump Tainted: G            E   4.0.4 #1

For 4.0.x, you _really_ need to update to 4.0.9 to get the following two patches.

cf8befcc1a55 netlink: Disable insertions/removals during rehash
18889a4315a5 netlink: Reset portid after netlink_insert failure

Guenter
