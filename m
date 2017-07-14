From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 18/22] gpio: acpi: fix string overflow for large pin numbers
Date: Fri, 14 Jul 2017 21:59:50 +0200
Message-ID: <CAK8P3a1tozFc7Rmmv04dovtieHcLpg1VHaeZpW_NKFw4w-fZug@mail.gmail.com>
References: <20170714120720.906842-1-arnd@arndb.de> <20170714120720.906842-19-arnd@arndb.de>
 <1500036740.29303.7.camel@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Mika Westerberg <mika.westerberg@linux.intel.com>,
        Linus Walleij <linus.walleij@linaro.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Guenter Roeck <linux@roeck-us.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        Networking <netdev@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        "James E . J . Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K . Petersen" <martin.petersen@oracle.com>,
        linux-scsi <linux-scsi@vger.kernel.org>,
        "the arch/x86 maintainers" <x86@kernel.org>,
        Hans de Goede <hdegoede@redhat.com>,
        "Rafael J. Wysocki" <rjw@rjwysocki.net>,
        Wei Yongjun <weiyongjun1@huawei.com>,
        linux-gpio@vger.kernel.org,
        ACPI Devel Maling L
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <1500036740.29303.7.camel@linux.intel.com>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 14, 2017 at 2:52 PM, Andy Shevchenko
<andriy.shevchenko@linux.intel.com> wrote:
> On Fri, 2017-07-14 at 14:07 +0200, Arnd Bergmann wrote:
>> gcc-7 notices that the pin_table is an array of 16-bit numbers,
>> but we assume it can be printed as a two-character hexadecimal
>> string:
>>
>> drivers/gpio/gpiolib-acpi.c: In function
>> 'acpi_gpiochip_request_interrupt':
>> drivers/gpio/gpiolib-acpi.c:206:24: warning: '%02X' directive writing
>> between 2 and 4 bytes into a region of size 3 [-Wformat-overflow=]
>>    sprintf(ev_name, "_%c%02X",
>>                         ^~~~
>> drivers/gpio/gpiolib-acpi.c:206:20: note: directive argument in the
>> range [0, 65535]
>>    sprintf(ev_name, "_%c%02X",
>>                     ^~~~~~~~~
>> drivers/gpio/gpiolib-acpi.c:206:3: note: 'sprintf' output between 5
>> and 7 bytes into a destination of size 5
>>    sprintf(ev_name, "_%c%02X",
>>    ^~~~~~~~~~~~~~~~~~~~~~~~~~~
>>     agpio->triggering == ACPI_EDGE_SENSITIVE ? 'E' : 'L',
>>     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>>     pin);
>>     ~~~~
>
>
> This is obviously a false positive warning.
>
> Here we have
> int pin = u16 pin_table[0] <= 255 (implying >= 0).
>
> I see few options how to make it more clear
> 1) your proposal;
> 2) use "%02hhX" instead;
> 3) use if (ret >= 0 && ret <= 255) condition.
>
> I would choose one of the 2-3.
>
> In case gcc will complain about 3), file a bug to gcc crazy warning.

Makes sense. I didn't remember the syntax for 2) and couldn't find
it in the man page when I first looked. This seems like a good solution
here.

I'm pretty sure I tried 3) a few times when the warning first showed
up last year, but couldn't get that to work. Filing a gcc bug also seems
like a good idea, but I should first see if it's already fixed. The version
I use for testing at the moment is from late April, and others may
have complained about that already.

      Arnd
