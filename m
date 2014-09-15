From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH] netdev: octeon_mgmt: Fix ISO C90 forbids mixed declarations
 and code warning.
Date: Mon, 15 Sep 2014 09:32:29 -0700
Message-ID: <5417149D.2070301@caviumnetworks.com>
References: <1410798223-21420-1-git-send-email-ddaney.cavm@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
        <linux-kernel@vger.kernel.org>, <linux-mips@linux-mips.org>,
        David Daney <david.daney@cavium.com>,
        Heinrich Schuchardt <xypron.glpk@gmx.de>,
        Joe Perches <joe@perches.com>
To: David Daney <ddaney.cavm@gmail.com>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1410798223-21420-1-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On 09/15/2014 09:23 AM, David Daney wrote:
> From: David Daney <david.daney@cavium.com>
>
> We were getting:
>
>    drivers/net/ethernet/octeon/octeon_mgmt.c:295:4: warning: ISO C90 forbids mixed declarations and code [-Wdeclaration-after-statement]
>
> The idea of the fix from Joe Perches.
>
> Signed-off-by: David Daney <david.daney@cavium.com>
> Cc: Heinrich Schuchardt <xypron.glpk@gmx.de>
> Cc: Joe Perches <joe@perches.com>

Actually Aaro Koskinen's similar patch was just committed to the net.git 
tree (commit	208f7ca4d4a6886256763c9c073775c5fdaf47eb), so this whole 
thing seems to have been an exercise in time wasting.

I don't really care which patch goes in at this point.  So I defer to 
davem et al.

David Daney


> ---
>
> This patch should supersede previous patches from Heinrich Schuchardt,
> and may be preferable as it touches fewer lines of code.
>
>   drivers/net/ethernet/octeon/octeon_mgmt.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
> index 979c698..5e10c1d 100644
> --- a/drivers/net/ethernet/octeon/octeon_mgmt.c
> +++ b/drivers/net/ethernet/octeon/octeon_mgmt.c
> @@ -290,12 +290,12 @@ static void octeon_mgmt_clean_tx_buffers(struct octeon_mgmt *p)
>   		/* Read the hardware TX timestamp if one was recorded */
>   		if (unlikely(re.s.tstamp)) {
>   			struct skb_shared_hwtstamps ts;
> -			memset(&ts, 0, sizeof(ts));
>   			/* Read the timestamp */
>   			u64 ns = cvmx_read_csr(CVMX_MIXX_TSTAMP(p->port));
>   			/* Remove the timestamp from the FIFO */
>   			cvmx_write_csr(CVMX_MIXX_TSCTL(p->port), 0);
>   			/* Tell the kernel about the timestamp */
> +			memset(&ts, 0, sizeof(ts));
>   			ts.hwtstamp = ns_to_ktime(ns);
>   			skb_tstamp_tx(skb, &ts);
>   		}
>
