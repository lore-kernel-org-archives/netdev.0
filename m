From: Adrian Bunk <bunk@stusta.de>
Subject: tg3_read_partno(): possible array overrun
Date: Mon, 6 Nov 2006 10:45:28 +0100
Message-ID: <20061106094527.GG5778@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:61452 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S1423659AbWKFJp2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Nov 2006 04:45:28 -0500
To: jgarzik@pobox.com, davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Coverity checker noted the following in drivers/net/tg3.c:

<--  snip  -->

...
static void __devinit tg3_read_partno(struct tg3 *tp)
{
        unsigned char vpd_data[256];
        int i;
...
        /* Now parse and find the part number. */
        for (i = 0; i < 256; ) {
                unsigned char val = vpd_data[i];
                int block_end;

                if (val == 0x82 || val == 0x91) {
                        i = (i + 3 +
                             (vpd_data[i + 1] +
                              (vpd_data[i + 2] << 8)));
                        continue;
                }

                if (val != 0x90)
                        goto out_not_found;

                block_end = (i + 3 +
                             (vpd_data[i + 1] +
                              (vpd_data[i + 2] << 8)));
                i += 3;
...

<--  snip  -->

The problem is that vpd_data[i + 2] could be vpd_data[255 + 2].

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

