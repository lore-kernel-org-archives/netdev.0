From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v4 4/9] em28xx: fix em28xx_dvb_init for KASAN
Date: Mon, 25 Sep 2017 14:41:30 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD007F521@AcuExch.aculab.com>
References: <20170922212930.620249-1-arnd@arndb.de>
 <20170922212930.620249-5-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Jiri Pirko <jiri@resnulli.us>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Michal Marek <mmarek@suse.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Kees Cook <keescook@chromium.org>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        "Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
        "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org
To: 'Arnd Bergmann' <arnd@arndb.de>,
        Mauro Carvalho Chehab <mchehab@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170922212930.620249-5-arnd@arndb.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann
> Sent: 22 September 2017 22:29
...
> It seems that this is triggered in part by using strlcpy(), which the
> compiler doesn't recognize as copying at most 'len' bytes, since strlcpy
> is not part of the C standard.

Neither is strncpy().

It'll almost certainly be a marker in a header file somewhere,
so it should be possibly to teach it about other functions.

	David
