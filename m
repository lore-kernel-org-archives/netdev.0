From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] Bluetooth: remove direct compilation of 6lowpan_iphc.c
Date: Fri, 17 Jan 2014 12:19:54 -0800
Message-ID: <4406CE8B-CB98-418A-98C7-2BB160A54ED5@holtmann.org>
References: <1389986964-5177-1-git-send-email-swarren@wwwdotorg.org>
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-zigbee-devel@lists.sourceforge.net,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Network Development <netdev@vger.kernel.org>,
	Jukka Rissanen <jukka.rissanen@linux.intel.com>,
	Stephen Warren <swarren@nvidia.com>
To: Stephen Warren <swarren@wwwdotorg.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1389986964-5177-1-git-send-email-swarren@wwwdotorg.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

> It's now built as a separate utility module, and enabling BT selects
> that module in Kconfig. This fixes:
> 
> net/ieee802154/built-in.o:(___ksymtab_gpl+lowpan_process_data+0x0): multiple definition of `__ksymtab_lowpan_process_data'
> net/bluetooth/built-in.o:(___ksymtab_gpl+lowpan_process_data+0x0): first defined here
> net/ieee802154/built-in.o:(___ksymtab_gpl+lowpan_header_compress+0x0): multiple definition of `__ksymtab_lowpan_header_compress'
> net/bluetooth/built-in.o:(___ksymtab_gpl+lowpan_header_compress+0x0): first defined here
> net/ieee802154/built-in.o: In function `lowpan_header_compress':
> net/ieee802154/6lowpan_iphc.c:606: multiple definition of `lowpan_header_compress'
> net/bluetooth/built-in.o:/home/swarren/shared/git_wa/kernel/kernel.git/net/bluetooth/../ieee802154/6lowpan_iphc.c:606: first defined here
> net/ieee802154/built-in.o: In function `lowpan_process_data':
> net/ieee802154/6lowpan_iphc.c:344: multiple definition of `lowpan_process_data'
> net/bluetooth/built-in.o:/home/swarren/shared/git_wa/kernel/kernel.git/net/bluetooth/../ieee802154/6lowpan_iphc.c:344: first defined here
> make[1]: *** [net/built-in.o] Error 1
> 
> (this change probably simply wasn't "git add"d to a53d34c3465b)
> 
> Fixes: a53d34c3465b ("net: move 6lowpan compression code to separate module")
> Fixes: 18722c247023 ("Bluetooth: Enable 6LoWPAN support for BT LE devices")
> Signed-off-by: Stephen Warren <swarren@nvidia.com>

seems that I missed the initial patch that changes this to build this as separate module. Please CC linux-bluetooth@vger.kernel.org so that we do not accidentally miss these changes.

Our initial idea was to create net/core/6lowpan_iphc.c or maybe net/6lowpan/iphc.c module to make it clear that this is independent from IEEE 802.15.4 and Bluetooth. However we started to do this inside net/ieee802154 to this started.

Should we do the change now and move it into its separate directory.

Regards

Marcel
