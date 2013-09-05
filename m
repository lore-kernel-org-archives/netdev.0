From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] openvswitch: Fix alignment of struct
	sw_flow_key.
Date: Thu, 5 Sep 2013 12:14:08 -0700
Message-ID: <CAEP_g=-pWd5XnnhWeEbCn8Z4s9kbicRU2doovt+XOWfr0UL8ow@mail.gmail.com>
References: <1378402887-17331-1-git-send-email-jesse@nicira.com>
	<20130905.141751.945639989861997124.davem@davemloft.net>
	<CAEP_g=8gcCtkv=no=HkVmS+NDWPM-Uu-SVyR+vb-YQ=7TWJsXA@mail.gmail.com>
	<20130905.144044.1053960608071929025.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20130905.144044.1053960608071929025.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 5, 2013 at 11:40 AM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
> Date: Thu, 5 Sep 2013 11:36:19 -0700
>
>> On Thu, Sep 5, 2013 at 11:17 AM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
>>> From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
>>> Date: Thu,  5 Sep 2013 10:41:27 -0700
>>>
>>>> -} __aligned(__alignof__(long));
>>>> +} __aligned(8); /* 8 byte alignment ensures this can be accessed as a long */
>>>
>>> This kind of stuff drives me crazy.
>>>
>>> If the issue is the type, therefore at least use an expression that
>>> mentions the type explicitly.  And mention the actual type that
>>> matters.  "long" isn't it.
>>
>> 'long' actually is the real type here.
>>
>> When doing comparisons, this structure is being accessed as a byte
>> array in 'long' sized chunks, not by its members. Therefore, the
>> compiler's alignment does not necessarily correspond to anything for
>> this purpose. It could be a struct full of u16's and we would still
>> want to access it in chunks of 'long'.
>>
>> To completely honest, I think the correct alignment should be
>> sizeof(long) because I know that 'long' is not always 8 bytes on all
>> architectures. However, you made the point before that this could
>> break the alignment of the 64-bit values on architectures where 'long'
>> is 32 bits wide, so 8 bytes is the generic solution.
>
> Look at net/core/flow.c:flow_key_compare().
>
> And then we annotate struct flowi with
>
> } __attribute__((__aligned__(BITS_PER_LONG/8)));
>
> Don't reinvent the wheel, either mimick how existing code does
> this kind of thing or provide a justification for doing it differently
> and update the existing cases to match and be consistent.

Sure, I'll send a new patch to use BITS_PER_LONG.
