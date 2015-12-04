From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next 3/3] vhost_net: basic polling support
Date: Fri, 4 Dec 2015 10:24:00 +0800
Message-ID: <5660F940.3000202@redhat.com>
References: <1448435489-5949-1-git-send-email-jasowang@redhat.com>
	<1448435489-5949-4-git-send-email-jasowang@redhat.com>
	<20151130124233-mutt-send-email-mst@redhat.com>
	<565D2D7D.4010903@redhat.com>
	<20151201163939-mutt-send-email-mst@redhat.com>
	<565E7BC3.2060107@redhat.com>
	<20151202143522-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20151202143522-mutt-send-email-mst@redhat.com>
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



On 12/02/2015 08:36 PM, Michael S. Tsirkin wrote:
> On Wed, Dec 02, 2015 at 01:04:03PM +0800, Jason Wang wrote:
>>
>> On 12/01/2015 10:43 PM, Michael S. Tsirkin wrote:
>>> On Tue, Dec 01, 2015 at 01:17:49PM +0800, Jason Wang wrote:
>>>> On 11/30/2015 06:44 PM, Michael S. Tsirkin wrote:
>>>>> On Wed, Nov 25, 2015 at 03:11:29PM +0800, Jason Wang wrote:
>>>>>>> This patch tries to poll for new added tx buffer or socket receive
>>>>>>> queue for a while at the end of tx/rx processing. The maximum time
>>>>>>> spent on polling were specified through a new kind of vring ioctl.
>>>>>>>
>>>>>>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>>>>> One further enhancement would be to actually poll
>>>>> the underlying device. This should be reasonably
>>>>> straight-forward with macvtap (especially in the
>>>>> passthrough mode).
>>>>>
>>>>>
>>>> Yes, it is. I have some patches to do this by replacing
>>>> skb_queue_empty() with sk_busy_loop() but for tap.
>>> We probably don't want to do this unconditionally, though.
>>>
>>>> Tests does not show
>>>> any improvement but some regression.
>>> Did you add code to call sk_mark_napi_id on tap then?
>>> sk_busy_loop won't do anything useful without.
>> Yes I did. Probably something wrong elsewhere.
> Is this for guest-to-guest?

Nope. Like you said below, since it requires NAPI so it was external
host to guest.

>  the patch to do napi
> for tap is still not upstream due to minor performance
> regression.  Want me to repost it?

Sure, I've played this a little bit in the past too.

>
>>>>  Maybe it's better to test macvtap.
>>> Same thing ...
>>>
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
