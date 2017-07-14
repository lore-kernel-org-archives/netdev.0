From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/22] isdn: divert: fix sprintf buffer overflow warning
Date: Fri, 14 Jul 2017 09:03:33 -0700 (PDT)
Message-ID: <20170714.090333.1855828185812848713.davem@davemloft.net>
References: <20170714120720.906842-1-arnd@arndb.de>
        <20170714120720.906842-9-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, isdn@linux-pingi.de,
        geliangtang@gmail.com, gregkh@linuxfoundation.org,
        torvalds@linux-foundation.org, linux@roeck-us.net,
        akpm@linux-foundation.org, netdev@vger.kernel.org,
        jejb@linux.vnet.ibm.com, martin.petersen@oracle.com,
        linux-scsi@vger.kernel.org, x86@kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170714120720.906842-9-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 14 Jul 2017 14:07:00 +0200

> One string we pass into the cs->info buffer might be too long,
> as pointed out by gcc:
> 
> drivers/isdn/divert/isdn_divert.c: In function 'll_callback':
> drivers/isdn/divert/isdn_divert.c:488:22: error: '%d' directive writing between 1 and 3 bytes into a region of size between 1 and 69 [-Werror=format-overflow=]
>  sprintf(cs->info, "%d 0x%lx %s %s %s %s 0x%x 0x%x %d %d %s\n",
>                    ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> drivers/isdn/divert/isdn_divert.c:488:22: note: directive argument in the range [0, 255]
> drivers/isdn/divert/isdn_divert.c:488:4: note: 'sprintf' output 25 or more bytes (assuming 129) into a destination of size 90
> 
> This is unlikely to actually cause problems, so let's use snprintf
> as a simple workaround to shut  up the warning and truncate the
> buffer instead.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
