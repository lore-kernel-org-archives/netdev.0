From: Noam Camus <noamc@ezchip.com>
Subject: RE: [PATCH] net: ezchip: fix address space confusion in nps_enet.c
Date: Tue, 8 Dec 2015 15:54:26 +0000
Message-ID: <DB5PR02MB11413338E829BFCBB7F086AED6080@DB5PR02MB1141.eurprd02.prod.outlook.com>
References: <33732958.3idC7H2UPT@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Tal Zilcer <talz@ezchip.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <33732958.3idC7H2UPT@wuerfel>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From: Arnd Bergmann [mailto:arnd@arndb.de] 
>Sent: Tuesday, December 08, 2015 5:29 PM
>To: David S. Miller
>Cc: Noam Camus; Tal Zilcer; netdev@vger.kernel.org; linux-kernel@vger.kernel.org; linux-arm-kernel@lists.infradead.org
>Subject: [PATCH] net: ezchip: fix address space confusion in nps_enet.c

>The nps_enet driver happily mixes virtual, physical and __iomem addresses, which are all different depending on the architecture and configuration.  That causes a warning when building the code on ARM with LPAE mode enabled:

>drivers/net/ethernet/ezchip/nps_enet.c: In function 'nps_enet_send_frame':
>drivers/net/ethernet/ezchip/nps_enet.c:370:13: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]

>but will also fail to work for other reasons.

>In this patch, I'm trying to change the code to use only normal kernel pointers, which I assume is what the author actually meant:

>* For reading or writing a 32-bit word that may be unaligned when
> an SKB contains unaligned data, I'm using get_unaligned/put_unaligned()
>  rather than memcpy_fromio/toio.

>* For converting a u8 pointer to a u32 pointer, I use a cast rather
>  than the incorrect virt_to_phys.

>* For copying a couple of bytes from one place to another while respecting
 > alignment, I use memcpy instead of memcpy_toio.

>Signed-off-by: Arnd Bergmann <arnd@arndb.de>

I have tested it on my simulator environment and driver compiles cleanly and runs happily without any problem.
Thank you.

Acked-by Noam Camus <noamc@ezchip.com>
