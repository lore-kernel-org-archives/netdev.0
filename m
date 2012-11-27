From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next RFC] pktgen: don't wait for the device who doesn't
	free skb immediately after sent
Date: Tue, 27 Nov 2012 14:45:13 +0800
Message-ID: <50B46179.4040809@redhat.com>
References: <1353916612-6357-1-git-send-email-jasowang@redhat.com>
	<20121126093728.0a10f97f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20121126093728.0a10f97f@nehalam.linuxnetplumber.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 11/27/2012 01:37 AM, Stephen Hemminger wrote:
> On Mon, 26 Nov 2012 15:56:52 +0800
> Jason Wang <jasowang@redhat.com> wrote:
>
>> Some deivces do not free the old tx skbs immediately after it has been sent
>> (usually in tx interrupt). One such example is virtio-net which optimizes for
>> virt and only free the possible old tx skbs during the next packet sending. This
>> would lead the pktgen to wait forever in the refcount of the skb if no other
>> pakcet will be sent afterwards.
>>
>> Solving this issue by introducing a new flag IFF_TX_SKB_FREE_DELAY which could
>> notify the pktgen that the device does not free skb immediately after it has
>> been sent and let it not to wait for the refcount to be one.
>>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> Another alternative would be using skb_orphan() and skb->destructor.
> There are other cases where skb's are not freed right away.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
Hi Stephen:

Do you mean registering a skb->destructor for pktgen then set and check 
bits in skb->tx_flag?
