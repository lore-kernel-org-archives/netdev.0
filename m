From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] rt2500usb: don't mark register accesses as inline
Date: Wed, 15 Feb 2017 08:48:59 +0100
Message-ID: <CAK8P3a2HfVqS76QHC4Z93r-L=Vvh-g+JsjE9kqut4VOUQVJLew@mail.gmail.com>
References: <20170214212846.2809141-1-arnd@arndb.de> <8760kcovf1.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stanislaw Gruszka <sgruszka@redhat.com>,
        Helmut Schaa <helmut.schaa@googlemail.com>,
        Mathias Kresin <dev@kresin.me>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8760kcovf1.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 15, 2017 at 6:49 AM, Kalle Valo <kvalo@codeaurora.org> wrote:
> Arnd Bergmann <arnd@arndb.de> writes:
>
>> When CONFIG_KASAN is set, we get a rather large stack here:
>>
>> drivers/net/wireless/ralink/rt2x00/rt2500usb.c: In function 'rt2500usb_set_device_state':
>> drivers/net/wireless/ralink/rt2x00/rt2500usb.c:1074:1: error: the frame size of 3032 bytes is larger than 100 bytes [-Werror=frame-larger-than=]
>>
>> If we don't force those functions to be inline, the compiler can figure this
>> out better itself and not inline the functions when doing so would be harmful,
>> reducing the stack size to a merge 256 bytes.
>>
>> Note that there is another problem that manifests in this driver, as a result
>> of the typecheck() macro causing even larger stack frames.
>>
>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>
> [...]
>
>> -static inline void rt2500usb_register_multiread(struct rt2x00_dev *rt2x00dev,
>> -                                             const unsigned int offset,
>> -                                             void *value, const u16 length)
>> -{
>> -     rt2x00usb_vendor_request_buff(rt2x00dev, USB_MULTI_READ,
>> -                                   USB_VENDOR_REQUEST_IN, offset,
>> -                                   value, length);
>> -}
>> -
>
> I guess you removed this because it was not actually used anywhere? Just
> checking.

Correct, if I just remove the 'inline' annotation, we get a warning about an
unused function here. Sorry for not mentioning that in the changelog.

    Arnd
