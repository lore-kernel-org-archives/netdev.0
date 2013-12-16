From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH -next] xen-netback: fix some error return code
Date: Mon, 16 Dec 2013 14:12:40 +0000
Message-ID: <1387203160.21086.1.camel@kazak.uk.xensource.com>
References: <CAPgLHd9aQQq-gLuNzGaYP2TSz=5Xk_GqgS=MSrAB7Tnn0nCydw@mail.gmail.com>
	 <20131216131313.GE12582@zion.uk.xensource.com>
	 <1387201238.10247.37.camel@kazak.uk.xensource.com>
	 <CAPgLHd_yD=s0xKXop8T47hvxw2MZD9PHZ9tKKB+45Y5uOHNUVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <yongjun_wei@trendmicro.com.cn>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:6247 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753554Ab3LPOMn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 09:12:43 -0500
In-Reply-To: <CAPgLHd_yD=s0xKXop8T47hvxw2MZD9PHZ9tKKB+45Y5uOHNUVQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-16 at 21:57 +0800, Wei Yongjun wrote:
> On 12/16/2013 09:40 PM, Ian Campbell wrote:
> > On Mon, 2013-12-16 at 13:13 +0000, Wei Liu wrote:
> >> On Mon, Dec 16, 2013 at 01:49:29PM +0800, Wei Yongjun wrote:
> >>> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> >>>
> >>> Fix to return -EPROTO error code instead of 0(overwrite by maybe_pull_tail())
> >>> if skb_partial_csum_set() return false.
> >>>
> >>> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> >>> ---
> >>>  drivers/net/xen-netback/netback.c | 16 ++++++++++++----
> >>>  1 file changed, 12 insertions(+), 4 deletions(-)
> >>>
> >>> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> >>> index 800496b..b16daa7 100644
> >>> --- a/drivers/net/xen-netback/netback.c
> >>> +++ b/drivers/net/xen-netback/netback.c
> >>> @@ -1108,8 +1108,10 @@ static int checksum_setup_ip(struct xenvif *vif, struct sk_buff *skb,
> >>>  			goto out;
> >>>  
> >>>  		if (!skb_partial_csum_set(skb, off,
> >>> -					  offsetof(struct tcphdr, check)))
> >>> +					  offsetof(struct tcphdr, check))) {
> >>> +			err = -EPROTO;
> >> Why is this needed? It is set to -EPROTO before the 'switch'.
> > Agreed.
> 
> As I said in the description, err is overwrited to 0 by the above
> 'err = maybe_pull_tail(...)' call in the same 'case XXX'.
> Refer to the source code:

What tree/commit is this? Neither Linus', net or net-next look like this
to me.

> 
> 1104                 err = maybe_pull_tail(skb,
> 1105                                       off + sizeof(struct tcphdr),
> 1106                                       MAX_IP_HDR_LEN);
> 1107                 if (err < 0)
> 1108                         goto out;
> 1109 
> 1110                 if (!skb_partial_csum_set(skb, off,
> 1111                                           offsetof(struct tcphdr, check)))
> 1112                         goto out;
> 
> 
> 
