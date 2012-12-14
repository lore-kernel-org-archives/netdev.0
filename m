From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] bridge: Bug fix for incorrect interpretation
 of MLDv2 maximum response code
Date: Thu, 13 Dec 2012 16:51:34 -0800
Message-ID: <20121213165134.68443089@nehalam.linuxnetplumber.net>
References: <50CA6DA5.1020101@sfc.wide.ad.jp>
	<20121213161201.6d2da433@nehalam.linuxnetplumber.net>
	<50CA7078.8070204@sfc.wide.ad.jp>
	<20121213162346.71c3779f@nehalam.linuxnetplumber.net>
	<50CA7449.8000305@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Ang Way Chuang <wcang@sfc.wide.ad.jp>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <50CA7449.8000305@sfc.wide.ad.jp>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, 14 Dec 2012 08:35:21 +0800
Ang Way Chuang <wcang@sfc.wide.ad.jp> wrote:

> On 14/12/2012 08:23, Stephen Hemminger wrote:
> > On Fri, 14 Dec 2012 08:19:04 +0800
> > Ang Way Chuang <wcang@sfc.wide.ad.jp> wrote:
> >
> >> On 14/12/2012 08:12, Stephen Hemminger wrote:
> >>> On Fri, 14 Dec 2012 08:07:01 +0800
> >>> Ang Way Chuang <wcang@sfc.wide.ad.jp> wrote:
> >>>
> >>>> This patch fixes the incorrect interpretation of endianness of MLDv2 maximum response
> >>>> code within bridge's multicast snooping code.
> >>>>
> >>>> Signed-off-by: Ang Way Chuang <wcang@sfc.wide.ad.jp>
> >>>> ---
> >>>> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> >>>> index 977c3ee..29c6283 100644
> >>>> --- a/net/bridge/br_multicast.c
> >>>> +++ b/net/bridge/br_multicast.c
> >>>> @@ -1172,7 +1172,7 @@ static int br_ip6_multicast_query(struct net_bridge *br,
> >>>>  		mld2q = (struct mld2_query *)icmp6_hdr(skb);
> >>>>  		if (!mld2q->mld2q_nsrcs)
> >>>>  			group = &mld2q->mld2q_mca;
> >>>> -		max_delay = mld2q->mld2q_mrc ? MLDV2_MRC(mld2q->mld2q_mrc) : 1;
> >>>> +		max_delay = mld2q->mld2q_mrc ? MLDV2_MRC(ntohs(mld2q->mld2q_mrc)) : 1;
> >>>>  	}
> >>>>  
> >>>>  	if (!group)
> >>> Already fixed as part of my patch to fix sparse warnings.
> >>> --
> >>> To unsubscribe from this list: send the line "unsubscribe netdev" in
> >>> the body of a message to majordomo@vger.kernel.org
> >>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>>
> >> aye, aye.
> > Yours looks cleaner (I added a temp variable). You might want to submit
> > patch to switch to your oneline version.
> >
> Well, the patch did get into the netdev mailing list. I think your direct reply arrived in my mailbox first before I received my own patch through netdev. By the way, I don't see your patch on net-next git. Otherwise, I wouldn't have gone through the trouble of debugging and testing it on my computer. Is there any other repo that I should watch out to avoid this kind of silly situation in the future?

You didn't see it because net-next tree is currently closed/idle until Dave opens it up for next release (3.9)
At this time, the only patches are those in the net tree: 	
  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git
Which is where fixes for the current release are staged for Linus.

commit eca2a43bb0d2c6ebd528be6acb30a88435abe307
Author: stephen hemminger <shemminger@vyatta.com>
Date:   Thu Dec 13 06:51:28 2012 +0000

    bridge: fix icmpv6 endian bug and other sparse warnings
    
    Fix the warnings reported by sparse on recent bridge multicast
    changes. Mostly just rcu annotation issues but in this case
    sparse found a real bug! The ICMPv6 mld2 query mrc
    values is in network byte order.
    
    Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
