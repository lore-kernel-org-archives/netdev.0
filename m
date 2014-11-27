From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next V2] tun/macvtap: use consume_skb() instead of
 kfree_skb() when needed
Date: Thu, 27 Nov 2014 13:02:04 +0800
Message-ID: <5476B04C.20304@redhat.com>
References: <1416987810-23263-1-git-send-email-jasowang@redhat.com> <20141126134742.GA5358@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141126134742.GA5358@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 11/26/2014 09:47 PM, Michael S. Tsirkin wrote:
> On Wed, Nov 26, 2014 at 03:43:30PM +0800, Jason Wang wrote:
>> >To be more friendly with drop monitor, we should only call kfree_skb() when
>> >the packets were dropped and use consume_skb() in other cases.
>> >
>> >Cc: Eric Dumazet<eric.dumazet@gmail.com>
>> >Signed-off-by: Jason Wang<jasowang@redhat.com>
>> >---
>> >Changes from V1:
>> >- check the return value of tun/macvtap_put_user()
>> >---
>> >  drivers/net/macvtap.c | 5 ++++-
>> >  drivers/net/tun.c     | 5 ++++-
>> >  2 files changed, 8 insertions(+), 2 deletions(-)
>> >
>> >diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
>> >index 42a80d3..c171ab6 100644
>> >--- a/drivers/net/macvtap.c
>> >+++ b/drivers/net/macvtap.c
>> >@@ -862,7 +862,10 @@ static ssize_t macvtap_do_read(struct macvtap_queue *q,
>> >  		}
>> >  		iov_iter_init(&iter, READ, iv, segs, len);
>> >  		ret = macvtap_put_user(q, skb, &iter);
>> >-		kfree_skb(skb);
>> >+		if (ret < 0)
> Maybe unlikely() here?
>

Better, will post V3.

Thanks
