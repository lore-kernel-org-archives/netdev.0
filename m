From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next v2 0/6] slight optimization of addr compare for
 some modules
Date: Wed, 18 Dec 2013 18:06:35 +0800
Message-ID: <52B173AB.6020901@huawei.com>
References: <52AEB8B3.5010405@huawei.com>	 <1387205111.18217.7.camel@joe-AO722> <52AF13F4.5040409@gmail.com>	 <1387207006.18217.28.camel@joe-AO722> <1387214748.18217.52.camel@joe-AO722>	 <52AFAFDC.2080807@huawei.com> <52B1611E.4090608@huawei.com> <1387358236.13593.36.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ding Tianhong <dthxman@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:44896 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753173Ab3LRKGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 05:06:54 -0500
In-Reply-To: <1387358236.13593.36.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/18 17:17, Joe Perches wrote:
> On Wed, 2013-12-18 at 16:47 +0800, Ding Tianhong wrote:
>> On 2013/12/17 9:58, Ding Tianhong wrote:
>>> On 2013/12/17 1:25, Joe Perches wrote:
>>>> These should still be inspected for appropriate use of
>>>> ether_addr_equal or ether_addr_equal_unaligned, but a
>>>> better cocci input sp-file is:
>>>>
>>>> $ cat ether_addr_equal_unaligned.cocci 
>>>> @@
>>>> expression e1;
>>>> expression e2;
>>>> @@
> []
>> There are too many places need to be changed, should I make it in one patch or several pathset,
>> pls give me some advise. thanks
> 
> Separate per-maintainer patches are generally good.
> It can take several attempts to get these applied
> in all the various trees.
> 
> So maybe 1 patch for each of most of these.  Maybe
> some of these like drivers/media, drivers/mtd and
> drivers/staging could probably be single patches.
> 

Hi Joe:

I found there is a bug in spatch, it could not deal with 
-       memcmp(e1, e2, \(6\|ETH_ALEN\)) != 0
+       !ether_addr_equal_unaligned(e1, e2)



diff -u -p a/caif/cfrfml.c b/caif/cfrfml.c
--- a/caif/cfrfml.c
+++ b/caif/cfrfml.c
@@ -79,7 +79,7 @@ static struct cfpkt *rfm_append(struct c
                return NULL;

        /* Verify correct header */
-       if (memcmp(seghead, rfml->seghead, 6) != 0)
+       if (!ether_addr_equal_unaligned(seghead, rfml->seghead) != 0)
                return NULL;

        tmppkt = cfpkt_append(rfml->incomplete_frm, pkt,


Regards
Ding 

> 
