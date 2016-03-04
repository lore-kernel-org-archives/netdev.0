From: "Valo, Kalle" <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH] ath9k: reduce stack usage in ar9003_aic_cal_post_process
Date: Fri, 4 Mar 2016 08:34:55 +0000
Message-ID: <87mvqezln6.fsf@kamboji.qca.qualcomm.com>
References: <1455278130-1831694-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: ath9k-devel <ath9k-devel@qca.qualcomm.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"ath9k-devel@lists.ath9k.org" <ath9k-devel@lists.ath9k.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Content-ID: <6A681C5ED5A5CC48B8136D4B22F84318@qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> writes:

> In some configurations, this function uses more than the warning limit
> of 1024 bytes:
>
> drivers/net/wireless/ath/ath9k/ar9003_aic.c: In function 'ar9003_aic_cal_post_process':
> drivers/net/wireless/ath/ath9k/ar9003_aic.c:434:1: error: the frame size of 1040 bytes is larger than 1024 bytes [-Werror=frame-larger-than=]
>
> It turns out that there are two large arrays on the stack here, but
> almost all the data in them is never used outside of the loop in
> which it gets written, so we can replace the array with a single
> instance.
>
> The .valid flag is used later, so I'm replacing the array of structures
> with an array of bools. An obvious follow-up optimization would be
> to replace it with a bitmask and set_bit()/find_first_bit()/
> find_last_bit()/... operations. However, I have not tested this patch,
> so I sticked to the simpler transformation that does the job of
> reducing the stack usage to a harmless level.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied to ath.git, thanks.

-- 
Kalle Valo
