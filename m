From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [10/14] wireless: cw1200: use __maybe_unused to hide pm functions_
Date: Tue,  8 Mar 2016 10:33:29 +0000 (UTC)
Message-ID: <20160308103329.3188E6074A@smtp.codeaurora.org>
References: <1456934350-1389172-11-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
 linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
 Solomon Peachy <pizza@shaftnet.org>, linux-arm-kernel@lists.infradead.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1456934350-1389172-11-git-send-email-arnd@arndb.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org


> The cw1200 uses #ifdef to check for CONFIG_PM, but then
> uses SIMPLE_DEV_PM_OPS, which leaves the references out when
> CONFIG_PM_SLEEP is not defined, so we get a warning with
> PM=y && PM_SLEEP=n:
> 
> drivers/net/wireless/st/cw1200/cw1200_spi.c:450:12: error: 'cw1200_spi_suspend' defined but not used [-Werror=unused-function]
> 
> This removes the incorrect #ifdef and instead uses a __maybe_unused
> annotation to let the compiler know it can silently drop
> the function definition.
> 
> For the DEV_PM_OPS definition, we can use an IS_ENABLED() check
> to avoid defining the structure when CONFIG_PM is not set without
> the #ifdef.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
