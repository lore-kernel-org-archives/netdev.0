From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v06 18/36] uapi linux/errqueue.h: include linux/time.h in
 user space
Date: Sun, 6 Aug 2017 16:26:50 -0400
Message-ID: <CAF=yD-LDo7_8k5rMtBkj-PASqTqz7Toub0qXBdGUR3Kqb4p4Tg@mail.gmail.com>
References: <20170806164428.2273-1-mikko.rapeli@iki.fi> <20170806164428.2273-19-mikko.rapeli@iki.fi>
 <CAF=yD-L2ntuH54J_SwN9WcpBMgkV_v0e-Q2Pu2mrQ3+1RozGFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: LKML <linux-kernel@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Network Development <netdev@vger.kernel.org>
To: Mikko Rapeli <mikko.rapeli@iki.fi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAF=yD-L2ntuH54J_SwN9WcpBMgkV_v0e-Q2Pu2mrQ3+1RozGFQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 6, 2017 at 4:23 PM, Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
> On Sun, Aug 6, 2017 at 12:44 PM, Mikko Rapeli <mikko.rapeli@iki.fi> wrote:
>> linux/time.h conflicts with user space header time.h. Try to be compatible
>> with both.
>>
>> Fixes userspace compilation error:
>>
>> error: array type has incomplete element type
>>  struct timespec ts[3];
>>
>> Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
>> Cc: Willem de Bruijn <willemb@google.com>
>> Cc: Soheil Hassas Yeganeh <soheil@google.com>
>> Cc: netdev@vger.kernel.org
>> ---
>>  include/uapi/linux/errqueue.h | 6 ++++++
>>  1 file changed, 6 insertions(+)
>>
>> diff --git a/include/uapi/linux/errqueue.h b/include/uapi/linux/errqueue.h
>> index 07bdce1f444a..b310b2c6d94f 100644
>> --- a/include/uapi/linux/errqueue.h
>> +++ b/include/uapi/linux/errqueue.h
>> @@ -3,6 +3,12 @@
>>
>>  #include <linux/types.h>
>>
>> +#ifdef __KERNEL__
>> +#include <linux/time.h>
>> +#else
>> +#include <time.h>
>> +#endif /* __KERNEL__ */
>
> This will break applications that include <linux/time.h> manually.

Also, the patch title reads "include <linux/time.h> in user space",
but it includes <time.h> in that environment.
