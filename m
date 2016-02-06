From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v2] hostap: avoid uninitialized variable use in hfa384x_get_rid
Date: Sat,  6 Feb 2016 11:59:45 +0000 (UTC)
Message-ID: <20160206115945.43B2460495@smtp.codeaurora.org>
References: <18181682.hKPVvnQWXk@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <j@w1.fi>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	Russell King - ARM Linux <linux@arm.linux.org.uk>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <18181682.hKPVvnQWXk@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> The driver reads a value from hfa384x_from_bap(), which may fail,
> and then assigns the value to a local variable. gcc detects that
> in in the failure case, the 'rlen' variable now contains
> uninitialized data:
> 
> In file included from ../drivers/net/wireless/intersil/hostap/hostap_pci.c:220:0:
> drivers/net/wireless/intersil/hostap/hostap_hw.c: In function 'hfa384x_get_rid':
> drivers/net/wireless/intersil/hostap/hostap_hw.c:842:5: warning: 'rec' may be used uninitialized in this function [-Wmaybe-uninitialized]
>   if (le16_to_cpu(rec.len) == 0) {
> 
> This restructures the function as suggested by Russell King, to
> make it more readable and get more reliable error handling, by
> handling each failure mode using a goto.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
