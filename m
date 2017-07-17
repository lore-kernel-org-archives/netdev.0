From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 14/22] [media] usbvision-i2c: fix format overflow warning
Date: Mon, 17 Jul 2017 14:57:50 +0200
Message-ID: <CAK8P3a3BWBQMcbg0hOoZa+N86dsEN88p9Wh0_cHSmKEur1uJhg@mail.gmail.com>
References: <20170714120720.906842-1-arnd@arndb.de> <20170714120720.906842-15-arnd@arndb.de>
 <f44cbc53-8c95-9fad-04d4-1fbf3708191c@xs4all.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Mauro Carvalho Chehab <mchehab@kernel.org>,
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
        Sakari Ailus <sakari.ailus@linux.intel.com>,
        Linux Media Mailing List <linux-media@vger.kernel.org>
To: Hans Verkuil <hverkuil@xs4all.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f44cbc53-8c95-9fad-04d4-1fbf3708191c@xs4all.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 17, 2017 at 2:53 PM, Hans Verkuil <hverkuil@xs4all.nl> wrote:
> On 14/07/17 14:07, Arnd Bergmann wrote:
>> gcc-7 notices that we copy a fixed length string into another
>> string of the same size, with additional characters:
>>
>> drivers/media/usb/usbvision/usbvision-i2c.c: In function 'usbvision_i2c_register':
>> drivers/media/usb/usbvision/usbvision-i2c.c:190:36: error: '%d' directive writing between 1 and 11 bytes into a region of size between 0 and 47 [-Werror=format-overflow=]
>>   sprintf(usbvision->i2c_adap.name, "%s-%d-%s", i2c_adap_template.name,
>>                                     ^~~~~~~~~~
>> drivers/media/usb/usbvision/usbvision-i2c.c:190:2: note: 'sprintf' output between 4 and 76 bytes into a destination of size 48
>>
>> We know this is fine as the template name is always "usbvision", so
>> we can easily avoid the warning by using this as the format string
>> directly.
>
> Hmm, how about replacing sprintf by snprintf? That feels a lot safer (this is very
> old code, it's not surprising it is still using sprintf).

With snprintf(), you will still get a -Wformat-truncation warning. One
of my patches
disables that warning by default, but Mauro likes build-testing with
"make W=1", so
it would still show up then.

However, we can do both: replace the string and use snprintf().

       Arnd
