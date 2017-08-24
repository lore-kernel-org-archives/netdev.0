From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] isdn: hisax: fix buffer overflow check
Date: Fri, 25 Aug 2017 01:15:42 +0200
Message-ID: <CAK8P3a0AVJom7cRetgmiT_SR=i5B2-uNy8sqqh_Ke8PfQOq99Q@mail.gmail.com>
References: <20170824225931.1602326-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Arnd Bergmann <arnd@arndb.de>, Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Karsten Keil <isdn@linux-pingi.de>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170824225931.1602326-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 25, 2017 at 12:58 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> gcc-8 warns about a corner case that can overflow a memcpy buffer when a
> length variable is negative. While the code checks for an overly large
> value, it does not check for a negative length that would get turned
> into a large positive number:
>
> In function 'memcpy',
>     inlined from 'skb_put_data' at include/linux/skbuff.h:2042:2,
>     inlined from 'l3dss1_cmd_global' at drivers/isdn/hisax/l3dss1.c:2219:4:
> include/linux/string.h:348:9: error: '__builtin_memcpy' reading 266 or more bytes from a region of size 265 [-Werror=stringop-overflow=]
>
> In function 'memcpy',
>     inlined from 'skb_put_data' at include/linux/skbuff.h:2042:2,
>     inlined from 'l3ni1_cmd_global' at drivers/isdn/hisax/l3ni1.c:2079:4:
> include/linux/string.h:348:9: error: '__builtin_memcpy' reading between 266 and 4294967295 bytes from a region of size 265 [-Werror=stringop-overflow=]
>
> It's not clear to me whether the warning should be here, or if this
> is another case of an optimization step in gcc causing a warning about
> something that would otherwise be silently ignored. Either way, making
> the length 'unsigned int' instead ensures that no overflow can happen
> here, and avoids the warning. The same code exists in two files, so I'm
> patching both the same way.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Sorry, I sent this out too early (trying to get fixes posted before my
vacation), please ignore this patch, it doesn't fix all the warnings I get
for this overflow problem.

     Arnd
