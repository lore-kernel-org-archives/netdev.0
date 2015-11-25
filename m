From: Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Subject: Re: [PATCH v1] net: stmmac: Free rx_skbufs before realloc
Date: Wed, 25 Nov 2015 16:13:08 +0100
Message-ID: <5655D004.4040502@st.com>
References: <1448181858-5935-1-git-send-email-zhengsq@rock-chips.com>	<1448181858-5935-2-git-send-email-zhengsq@rock-chips.com>
 <20151124.130924.1365382562223060152.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, dianders-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <zhengsq-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20151124.130924.1365382562223060152.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-rockchip/>
List-Post: <mailto:linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-rockchip" <linux-rockchip-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello

On 11/24/2015 7:09 PM, David Miller wrote:
> From: Shunqian Zheng <zhengsq-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
> Date: Sun, 22 Nov 2015 16:44:18 +0800
>
>> From: ZhengShunQian <zhengsq-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
>>
>> The init_dma_desc_rings() may realloc the rx_skbuff[] when
>> suspend and resume. This patch free the rx_skbuff[] before
>> reallocing memory.
>>
>> Signed-off-by: ZhengShunQian <zhengsq-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
>
> This isn't really the right way to fix this.
>
> I see two reasonable approaches:
>
> 1) suspend liberates the RX ring, although this approach is less
>     desirable
>
> 2) resume doesn't try to allocate already populated RX ring
>     entries
>
> Freeing the whole RX ring just to allocate it again immediately
> makes no sense at all and is wasteful work.

This is a bug in this driver version that, to be honest, we fixed with
the first approach on STi kernel.
The patch just called the dma_free_rx_skbufs(priv) in the suspend.
I can give you this patch that is tested on my side too.
But! I do think we should move on second approach.
Indeed, also on ST platforms, when we play with suspend states
the DDR although in self-refresh the data are not lost at all.
No reason to free and reallocate all in suspend/resume.
I can test that and then provide another patch to this mailing list
asap.

Let me know.
peppe
