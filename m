From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next 3/3] vhost_net: basic polling support
Date: Wed, 2 Dec 2015 13:04:03 +0800
Message-ID: <565E7BC3.2060107@redhat.com>
References: <1448435489-5949-1-git-send-email-jasowang@redhat.com>
 <1448435489-5949-4-git-send-email-jasowang@redhat.com>
 <20151130124233-mutt-send-email-mst@redhat.com> <565D2D7D.4010903@redhat.com>
 <20151201163939-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151201163939-mutt-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 12/01/2015 10:43 PM, Michael S. Tsirkin wrote:
> On Tue, Dec 01, 2015 at 01:17:49PM +0800, Jason Wang wrote:
>>
>> On 11/30/2015 06:44 PM, Michael S. Tsirkin wrote:
>>> On Wed, Nov 25, 2015 at 03:11:29PM +0800, Jason Wang wrote:
>>>>> This patch tries to poll for new added tx buffer or socket receive
>>>>> queue for a while at the end of tx/rx processing. The maximum time
>>>>> spent on polling were specified through a new kind of vring ioctl.
>>>>>
>>>>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>>> One further enhancement would be to actually poll
>>> the underlying device. This should be reasonably
>>> straight-forward with macvtap (especially in the
>>> passthrough mode).
>>>
>>>
>> Yes, it is. I have some patches to do this by replacing
>> skb_queue_empty() with sk_busy_loop() but for tap.
> We probably don't want to do this unconditionally, though.
>
>> Tests does not show
>> any improvement but some regression.
> Did you add code to call sk_mark_napi_id on tap then?
> sk_busy_loop won't do anything useful without.

Yes I did. Probably something wrong elsewhere.

>
>>  Maybe it's better to test macvtap.
> Same thing ...
>
