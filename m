From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rt2x00: improve calling conventions for register
 accessors
Date: Mon, 15 May 2017 10:40:52 -0400 (EDT)
Message-ID: <20170515.104052.1376354562934671974.davem@davemloft.net>
References: <20170515134711.2770374-1-arnd@arndb.de>
        <20170515142520.GA13996@redhat.com>
        <CAK8P3a1xYah7_4=DAcN+M83noUQyLZ9hV=WWD0Q79sQrFsoroA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sgruszka@redhat.com, helmut.schaa@googlemail.com,
        kvalo@codeaurora.org, daniel@makrotopia.org, dev@kresin.me,
        johannes.berg@intel.com, pozega.tomislav@gmail.com,
        vasilugin@yandex.ru, roman@advem.lv,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK8P3a1xYah7_4=DAcN+M83noUQyLZ9hV=WWD0Q79sQrFsoroA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 15 May 2017 16:36:45 +0200

> On Mon, May 15, 2017 at 4:28 PM, Stanislaw Gruszka <sgruszka@redhat.com> wrote:
>> On Mon, May 15, 2017 at 03:46:55PM +0200, Arnd Bergmann wrote:
>>> With CONFIG_KASAN enabled and gcc-7, we get a warning about rather high
>>> stack usage (with a private patch set I have to turn on this warning,
>>> which I intend to get into the next kernel release):
>>>
>>> wireless/ralink/rt2x00/rt2800lib.c: In function 'rt2800_bw_filter_calibration':
>>> wireless/ralink/rt2x00/rt2800lib.c:7990:1: error: the frame size of 2144 bytes is larger than 1536 bytes [-Werror=frame-larger-than=]
>>>
>>> The problem is that KASAN inserts a redzone around each local variable that
>>> gets passed by reference, and the newly added function has a lot of them.
>>> We can easily avoid that here by changing the calling convention to have
>>> the output as the return value of the function. This should also results in
>>> smaller object code, saving around 4KB in .text with KASAN, or 2KB without
>>> KASAN.
>>>
>>> Fixes: 41977e86c984 ("rt2x00: add support for MT7620")
>>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>>> ---
>>>  drivers/net/wireless/ralink/rt2x00/rt2800lib.c | 319 +++++++++++++------------
>>>  1 file changed, 164 insertions(+), 155 deletions(-)
>>
>> We have read(, &val) calling convention since forever in rt2x00 and that
>> was never a problem. I dislike to change that now to make some tools
>> happy, I think problem should be fixed in the tools instead.
> 
> How about adding 'depends on !KASAN' in Kconfig instead?

Please let's not go down that route and make such facilities less
useful due to decreased coverage.

Thanks.
