From: =?UTF-8?Q?Vicente_Jim=C3=A9nez?= <googuy@gmail.com>
Subject: Re: [PATCH] icmp: Restore resistence to abnormal messages
Date: Thu, 17 Nov 2016 02:17:44 +0100
Message-ID: <CAO1wt+aOv8K-16geLxO=qzp8cVTkFPiTMxV6WNWS9Ggx+tZeKg@mail.gmail.com>
References: <20161111202018.13795-1-googuy@gmail.com> <20161114.133646.1687576478968660327.davem@davemloft.net>
 <CAO1wt+b4OkJ4DmJ7_hUj_oKj4p_rRMuKUVpiBY7MSFMa=0WKQg@mail.gmail.com>
 <20161115.115657.798577230951109692.davem@redhat.com> <20161115173024.GD30581@breakpoint.cc>
 <CAO1wt+aZjRE_KTY0iRNJryeHvehrK6kuGMn6wOOeFuT1ncpPxA@mail.gmail.com> <20161116011404.GF30581@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@redhat.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161116011404.GF30581@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 16, 2016 at 2:14 AM, Florian Westphal <fw@strlen.de> wrote:
> Vicente Jim=C3=A9nez <googuy@gmail.com> wrote:
>> 1- add warning with pr_warn_ratelimited. I like this idea. I also
>> though about adding some message but I have no kernel experience and I
>> preferred to have just a working solution.
>
> I added this only to show whats happening.
>
> I don't like such printks because end users can't do anything about it.
>
What about using net_dbg_ratelimited macro? it only adds messages if
debug is enabled.

>
>> Finally, both patches decrement current packet by a value: Mine by 2
>> and Florian's by 8 bytes. Both arbitrary values. Personally I prefer
>> to go by small steps. If the small step fails, it just iterate again
>> and with 4 iterations, my patch also decrement the original value by 8
>> bytes (4x2).
>> Basically they are the same but my patch take smaller steps and miss
>> the warning message.
>
> IIRC I chose 8 because connection recovered faster in my case.
>
> I have not experienced this issue again (I dropped the patch from
> my kernel at some point and the connection stalls did not reappear so
> this got fixed elsewhere).
My issue is permanent for now in various locations. We have to
decrease MTU manually on all devices with newer kernels. We don't have
direct access to those abnormal routers because they are managed by a
communication provider that think the network had no problem because
all their Windows machines apparently work perfectly.

--=20
cheers
vicente
