From: Manoj Gupta <manojgupta@chromium.org>
Subject: Re: [PATCH] nfp: convert nfp_eth_set_bit_config() into a macro
Date: Wed, 4 Oct 2017 18:50:04 -0700
Message-ID: <CAAMbb05o=50E9_MDuuo1uSTKbr-=Vy4gLgD0Bg-8pMMCcL2kjw@mail.gmail.com>
References: <20171003200546.165731-1-mka@chromium.org> <1507140439.4434.14.camel@perches.com>
 <20171004184957.GO173745@google.com> <20171004152203.2a4f564d@cakuba.netronome.com>
 <20171004231649.GP173745@google.com> <20171004162550.20edf18c@cakuba.netronome.com>
 <CAAMbb06DaOY1cnSXkuL0ZMSGzpwhfi_3d87mt8FMv+iYKDG03w@mail.gmail.com> <20171004175603.4ba68737@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Matthias Kaehlcke <mka@chromium.org>,
        Joe Perches <joe@perches.com>,
        "David S . Miller" <davem@davemloft.net>,
        Simon Horman <simon.horman@netronome.com>,
        Dirk van der Merwe <dirk.vandermerwe@netronome.com>,
        oss-drivers@netronome.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Renato Golin <renato.golin@linaro.org>,
        Guenter Roeck <groeck@chromium.org>,
        Doug Anderson <dianders@chromium.org>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171004175603.4ba68737@cakuba.netronome.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 4, 2017 at 5:56 PM, Jakub Kicinski
<jakub.kicinski@netronome.com> wrote:
> On Wed, 4 Oct 2017 17:38:22 -0700, Manoj Gupta wrote:
>> On Wed, Oct 4, 2017 at 4:25 PM, Jakub Kicinski wrote:
>> > On Wed, 4 Oct 2017 16:16:49 -0700, Matthias Kaehlcke wrote:
>> >> > > Thanks for the suggestion. This seems a viable alternative if David
>> >> > > and the NFP owners can live without the extra checking provided by
>> >> > > __BF_FIELD_CHECK.
>> >> >
>> >> > The reason the __BF_FIELD_CHECK refuses to compile non-constant masks
>> >> > is that it will require runtime ffs on the mask, which is potentially
>> >> > costly.  I would also feel quite stupid adding those macros to the nfp
>> >> > driver, given that I specifically created the bitfield.h header to not
>> >> > have to reimplement these in every driver I write/maintain.
>> >>
>> >> That make sense, thanks for providing more context.
>> >>
>> >> > Can you please test the patch I provided in the other reply?
>> >>
>> >> With this patch there are no errors when building the kernel with
>> >> clang.
>> >
>> > Cool, thanks for checking!  I will run it through full tests and queue
>> > for upstreaming :)
>>
>> Just to let you know, using __BF_FIELD_CHECK macro will not Link with
>> -O0 (GCC or Clang)  since references to __compiletime_assert_xxx will
>> not be cleaned up.
>
> Do you mean the current nfp_eth_set_bit_config() will not work with -O0
> on either complier, or any use of __BF_FIELD_CHECK() will not compile
> with -O0?

Any use of __BF_FIELD_CHECK. The code will compile but not link since
calls to ____compiletime_assert_xxx (added by compiletime_assert
macro) will not be removed in -O0.

Thanks,
Manoj
