From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Subject: Re: [PATCH] Use nfmark as a key for u32 classifier
Date: Mon, 8 Nov 2004 12:06:50 +0200 (EET)
Message-ID: <Pine.LNX.4.61.0411081204290.9229@webhosting.rdsbv.ro>
References: <Pine.LNX.4.61.0411051317330.23651@webhosting.rdsbv.ro>
 <1099669841.1026.18.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: linux-net@vger.kernel.org, lartc@mailman.ds9a.nl,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1099669841.1026.18.camel@jzny.localdomain>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I think this is an ok midterm solution and should be applied.
Thanks.

> One comment Catalin: Can you resend the patch  make this a selectable
> choice via kconfig?
Yes, of course.
Also, as a bonus, I will add a mask. Something like this:
tc filter add dev eth0 protocol ip parent 1:0 prio 5 u32 \
 	match mark 0x0090 0xffff \
                           ^^^^^^
 	flowid 1:90

It's ok?

> Eventually  - we should kill this + the indev choices on u32 and move it
> up one so that we can have all filters capable of following filters from
> other classifiers. As a matter of fact we already have this feature but
> it is a little on the inefficient side at the moment.

It will be very good. It will add the missing flexibility.
I'll try to cook up something.

>
> cheers,
> jamal
>
> On Fri, 2004-11-05 at 06:38, Catalin(ux aka Dino) BOIE wrote:
>> Hello!
>>
>> I am glad to announce a patch for u32 to allow matches on nfmark.
>> The patch is non intrusive (few lines).
>>
>> Why I did this? Because fw classifier cannot be used together with u32.
>> For example, now, you cannot match a mark of 0x90 and a destination
>> port of 80. I know you can do it with iptables to do the marking, but if
>> you use Jamal actions to apply mark to policed packets, you need this.
>>
>> All stuff can be found at http://kernel.umbrella.ro/ also.
>>
>> Dave, please consider adding this patch.
>>
>> Stephen, if Dave accepts the patch, please apply the iproute2 patch. Thank
>> you.
>>
>> Signed-off-by: Catalin(ux aka Dino) BOIE <catab at umbrella.ro>
>>
>> Thank you for you time.
>> ---
>> Catalin(ux aka Dino) BOIE
>> catab at deuroconsult.ro
>> http://kernel.umbrella.ro/
>

---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/
