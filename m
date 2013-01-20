From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH] firewire net: Ensure checksumming in upper layer.
Date: Sun, 20 Jan 2013 10:50:58 +0100
Message-ID: <20130120105058.1aee26c4@stein>
References: <50FBA02C.9030203@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <50FBA02C.9030203@linux-ipv6.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Jan 20 YOSHIFUJI Hideaki wrote:
> It is wrong to set skb->ip_summed to CHECKSUM_UNNECESSARY unless
> the device has already checked it.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
>  drivers/firewire/net.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
> index e7a711f5..df6a1ca 100644
> --- a/drivers/firewire/net.c
> +++ b/drivers/firewire/net.c
> @@ -520,7 +520,7 @@ static int fwnet_finish_incoming_packet(struct net_device *net,
>  	dev = netdev_priv(net);
>  	/* Write metadata, and then pass to the receive level */
>  	skb->dev = net;
> -	skb->ip_summed = CHECKSUM_UNNECESSARY;  /* don't check it */
> +	skb->ip_summed = CHECKSUM_NONE;
>  
>  	/*
>  	 * Parse the encapsulation header. This actually does the job of

Indeed neither the device nor the lower drivers check protocol checksums.
But the CRCs of the encapsulating 1394 packets are checked in hardware.
Shall protocol checksums be verified regardless?
-- 
Stefan Richter
-=====-===-= ---= =-=--
http://arcgraph.de/sr/

------------------------------------------------------------------------------
Master Visual Studio, SharePoint, SQL, ASP.NET, C# 2012, HTML5, CSS,
MVC, Windows 8 Apps, JavaScript and much more. Keep your skills current
with LearnDevNow - 3,200 step-by-step video tutorials by Microsoft
MVPs and experts. ON SALE this month only -- learn more at:
http://p.sf.net/sfu/learnmore_123012
