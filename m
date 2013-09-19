From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH net 2/3] lib: introduce upper case hex ascii helpers
Date: Thu, 19 Sep 2013 11:57:22 +0200
Message-ID: <523ACA82.6070902@hartkopp.net>
References: <1379093833-4949-1-git-send-email-nautsch2@gmail.com> <1379093833-4949-3-git-send-email-nautsch2@gmail.com> <CACnwZYdBocYEjASpKCNZ6cfLNpzxeLxaVjLCHwxwsYO+P14tAQ@mail.gmail.com> <20130914213546.ae435cdd.akpm@linux-foundation.org> <523AC615.9020204@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Thiago Farina <tfransosi@gmail.com>,
	Andre Naujoks <nautsch2@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Arnd Bergmann <arnd@arndb.de>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>,
	Jason Baron <jbaron@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux list <linux-kernel@vger.kernel.org>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <523AC615.9020204@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19.09.2013 11:38, Marc Kleine-Budde wrote:
> On 09/15/2013 06:35 AM, Andrew Morton wrote:
>> On Sun, 15 Sep 2013 01:27:03 -0300 Thiago Farina <tfransosi@gmail.com> wrote:
>>
>>> On Fri, Sep 13, 2013 at 2:37 PM, Andre Naujoks <nautsch2@gmail.com> wrote:
>>>> To be able to use the hex ascii functions in case sensitive environments
>>>> the array hex_asc_upper[] and the needed functions for hex_byte_pack_upper()
>>>> are introduced.
>>>>
>>>> Signed-off-by: Andre Naujoks <nautsch2@gmail.com>
>>>> ---
>>>>  include/linux/kernel.h | 11 +++++++++++
>>>>  lib/hexdump.c          |  2 ++
>>>>  2 files changed, 13 insertions(+)
>>>>
>>>> diff --git a/include/linux/kernel.h b/include/linux/kernel.h
>>>> index 482ad2d..672ddc4 100644
>>>> --- a/include/linux/kernel.h
>>>> +++ b/include/linux/kernel.h
>>>> @@ -439,6 +439,17 @@ static inline char *hex_byte_pack(char *buf, u8 byte)
>>>>         return buf;
>>>>  }
>>>>
>>>> +extern const char hex_asc_upper[];
>>>> +#define hex_asc_upper_lo(x)    hex_asc_upper[((x) & 0x0f)]
>>>> +#define hex_asc_upper_hi(x)    hex_asc_upper[((x) & 0xf0) >> 4]
>>> Does using a macro instead of a real function (static inline)
>>> generates a better code?
>>
>> Yes, a static inline would be nicer, but these are derived from
>> hex_asc_lo/hex_asc_hi.  If we change one we should change the other
>> and that becomes a separate cleanup.  So I think this patch is
>> OK as-is.
> 
> Is this an Acked-by?
> 
>> Also, it would make sense to get all the *hex* stuff out of kernel.h
>> and into a new header file (hexchar.h?).  They're a clean
>> self-contained thing and kernel.h is rather a dumping ground.
> 
> Who is taking this series?

Andre suggested that Dave Miller could take these three patches for 3.12 as
they are mainly network fixes:

http://marc.info/?l=linux-can&m=137909384116115&w=2

Regards,
Oliver


