From: Igor Mitsyanko <igor.mitsyanko.os@quantenna.com>
Subject: Re: linux-next: build failure after merge of the
 wireless-drivers-next tree
Date: Wed, 7 Jun 2017 19:43:18 -0700
Message-ID: <3594bd0d-e2b4-a380-ba06-8dedbbcbe11f@quantenna.com>
References: <20170608122759.7ffda0c3@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Dmitrii Lebed <dlebed@quantenna.com>,
        Sergei Maksimenko <smaksimenko@quantenna.com>,
        Sergey Matyukevich <smatyukevich@quantenna.com>,
        Bindu Therthala <btherthala@quantenna.com>,
        Huizhao Wang <hwang@quantenna.com>,
        Kamlesh Rath <krath@quantenna.com>,
        Avinash Patil <avinashp@quantenna.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        Kalle Valo <kvalo@codeaurora.org>,
        Wireless <linux-wireless@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170608122759.7ffda0c3@canb.auug.org.au>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/07/2017 07:27 PM, Stephen Rothwell wrote:
> 
> External Email
> 
> 
> Hi all,
> 
> After merging the wireless-drivers-next tree, today's linux-next build
> (x86_64 allmodconfig) failed like this:
> 
> drivers/net/wireless/quantenna/qtnfmac/core.c: In function 'qtnf_core_net_attach':
> drivers/net/wireless/quantenna/qtnfmac/core.c:319:5: error: 'struct net_device' has no member named 'destructor'
>    dev->destructor = free_netdev;
>       ^
> 
> Caused by commit
> 
>    98f44cb0655c ("qtnfmac: introduce new FullMAC driver for Quantenna chipsets")
> 
> interacting with commit
> 
>    cf124db566e6 ("net: Fix inconsistent teardown and release of private netdev state.")
> 
> from the net tree.
> 
> I applied this merge fix patch for today.

Hi Stephen,
thanks. As I understand, you've applied this patch during a merge and no 
further actions are required, correct?


> 
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Thu, 8 Jun 2017 12:24:08 +1000
> Subject: [PATCH] qtnfmac: fix up for "net: Fix inconsistent teardown and
>   release of private netdev state."
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

Acked-by: Igor Mitsyanko <igor.mitsyanko.os@quantenna.com>

> ---
>   drivers/net/wireless/quantenna/qtnfmac/core.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/quantenna/qtnfmac/core.c b/drivers/net/wireless/quantenna/qtnfmac/core.c
> index c5ac252464f4..f053532c0e87 100644
> --- a/drivers/net/wireless/quantenna/qtnfmac/core.c
> +++ b/drivers/net/wireless/quantenna/qtnfmac/core.c
> @@ -316,7 +316,7 @@ int qtnf_core_net_attach(struct qtnf_wmac *mac, struct qtnf_vif *vif,
>          vif->netdev = dev;
> 
>          dev->netdev_ops = &qtnf_netdev_ops;
> -       dev->destructor = free_netdev;
> +       dev->needs_free_netdev = true;
>          dev_net_set(dev, wiphy_net(wiphy));
>          dev->ieee80211_ptr = &vif->wdev;
>          dev->ieee80211_ptr->iftype = iftype;
> --
> 2.11.0
> 
> --
> Cheers,
> Stephen Rothwell
> 
