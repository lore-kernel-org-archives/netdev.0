From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 17/22] platform/x86: alienware-wmi: fix format string
 overflow warning
Date: Fri, 14 Jul 2017 21:37:08 +0200
Message-ID: <CAK8P3a2dRg9vepvM7mOyg14E4JCd51oJ-ZWzr+au=N+puwWayA@mail.gmail.com>
References: <20170714120720.906842-1-arnd@arndb.de> <20170714120720.906842-18-arnd@arndb.de>
 <CAHp75Vd2eZAj++QdGraspjpTX=VPVR6qY+iCZiHsySGvUcGVmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Darren Hart <dvhart@infradead.org>,
        Andy Shevchenko <andy@infradead.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Guenter Roeck <linux@roeck-us.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        netdev <netdev@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        "James E . J . Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K . Petersen" <martin.petersen@oracle.com>,
        linux-scsi <linux-scsi@vger.kernel.org>,
        "x86@kernel.org" <x86@kernel.org>,
        Mario Limonciello <mario.limonciello@dell.com>,
        Arvind Yadav <arvind.yadav.cs@gmail.com>,
        Platform Driver <platform-driver-x86@vger.kernel.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHp75Vd2eZAj++QdGraspjpTX=VPVR6qY+iCZiHsySGvUcGVmQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 14, 2017 at 9:18 PM, Andy Shevchenko
<andy.shevchenko@gmail.com> wrote:
> On Fri, Jul 14, 2017 at 3:07 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>> gcc points out a possible format string overflow for a large value of 'zone':
>>
>> drivers/platform/x86/alienware-wmi.c: In function 'alienware_wmi_init':
>> drivers/platform/x86/alienware-wmi.c:461:24: error: '%02X' directive writing between 2 and 8 bytes into a region of size 6 [-Werror=format-overflow=]
>>    sprintf(buffer, "zone%02X", i);
>>                         ^~~~
>> drivers/platform/x86/alienware-wmi.c:461:19: note: directive argument in the range [0, 2147483646]
>>    sprintf(buffer, "zone%02X", i);
>>                    ^~~~~~~~~~
>> drivers/platform/x86/alienware-wmi.c:461:3: note: 'sprintf' output between 7 and 13 bytes into a destination of size 10
>>
>> While the zone should never be that large, it's easy to make the
>> buffer a few bytes longer so gcc can prove this to be safe.
>
> Please, be a bit smarter on such fixes.
>
> Here we need to convert
>
> int i;
>
> to
>
> u8 i;

That was my first impulse, but then I decided not to change the
idiomatic 'int i' for the index variable to 'u8' as that would be
less idiomatic.

> I will take it after addressing above.
>
> P.S. You may do this change across the file.

How about changing it to 'u8 zone'?

     Arnd
