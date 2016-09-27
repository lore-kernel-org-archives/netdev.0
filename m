From: Vishwanath Pai <pai.vishwain@gmail.com>
Subject: Re: [PATCH v3 2/2] netfilter: Create revision 2 of xt_hashlimit to
 support higher pps rates
Date: Tue, 27 Sep 2016 03:35:15 -0400
Message-ID: <CAGt3NP83Xw0rC8dfcU8GJ0UdJGxkkbS-oD96nHDkdtQuHHrQfA@mail.gmail.com>
References: <20160922164344.GB20423@akamai.com> <CAML_gOdcrnmuHkxA1xAb2HDXHpo+=+sw+oJBfKXF3ijApsjTqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vishwanath Pai <vpai@akamai.com>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Josh Hunt <johunt@akamai.com>, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org
To: Liping Zhang <zlpnobody@gmail.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CAML_gOdcrnmuHkxA1xAb2HDXHpo+=+sw+oJBfKXF3ijApsjTqg@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 27, 2016 at 12:15 AM, Liping Zhang <zlpnobody@gmail.com> wrote:
> Hi Vishwanath,
>
> 2016-09-23 0:43 GMT+08:00 Vishwanath Pai <vpai@akamai.com>:
>>
>>  /* Precision saver. */
>> -static u32 user2credits(u32 user)
>> +static u64 user2credits(u64 user, int revision)
>>  {
>> -       /* If multiplying would overflow... */
>> -       if (user > 0xFFFFFFFF / (HZ*CREDITS_PER_JIFFY_v1))
>> -               /* Divide first. */
>> -               return (user / XT_HASHLIMIT_SCALE_v1) *\
>> -                                       HZ * CREDITS_PER_JIFFY_v1;
>> +       if (revision == 1) {
>> +               /* If multiplying would overflow... */
>> +               if (user > 0xFFFFFFFF / (HZ*CREDITS_PER_JIFFY_v1))
>> +                       /* Divide first. */
>> +                       return (user / XT_HASHLIMIT_SCALE_v1) *\
>> +                                               HZ * CREDITS_PER_JIFFY_v1;
>> +
>> +               return (user * HZ * CREDITS_PER_JIFFY_v1) \
>> +                                               / XT_HASHLIMIT_SCALE_v1;
>> +       } else {
>> +               if (user > 0xFFFFFFFFFFFFFFFF / (HZ*CREDITS_PER_JIFFY))
>> +                       return (user / XT_HASHLIMIT_SCALE) *\
>> +                                               HZ * CREDITS_PER_JIFFY;
>>
>> -       return (user * HZ * CREDITS_PER_JIFFY_v1) / XT_HASHLIMIT_SCALE_v1;
>> +               return (user * HZ * CREDITS_PER_JIFFY) / XT_HASHLIMIT_SCALE;
>> +       }
>>  }
>>
>
> In my memory, 64-bit division operation should be replaced by
> div_u64 or div64_u64, otherwise on some 32-bit architecture
> systems, link error will happen. Something like this:
> ... undefined reference to `__udivdi3'.

I did not know that, thanks for pointing it out. I will send a patch
to fix this.

-Vishwanath
