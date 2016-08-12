From: Gerard Garcia <ggarcia@abra.uab.cat>
Subject: Re: [PATCH 1/3] vsockmon: Add tap functions.
Date: Fri, 12 Aug 2016 16:15:03 +0200
Message-ID: <e551618e-4a10-3973-73fe-47542758b6e1@deic.uab.cat>
References: <20160808161442.16038-1-ggarcia@deic.uab.cat>
 <20160808161442.16038-2-ggarcia@deic.uab.cat>
 <20160810114033.GA10461@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhansen@vmware.com, mst@redhat.com
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33601 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447AbcHLOPG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 10:15:06 -0400
Received: by mail-wm0-f67.google.com with SMTP id o80so3107645wme.0
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 07:15:06 -0700 (PDT)
In-Reply-To: <20160810114033.GA10461@stefanha-x1.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/10/2016 01:40 PM, Stefan Hajnoczi wrote:
> On Mon, Aug 08, 2016 at 06:14:40PM +0200, ggarcia@abra.uab.cat wrote:
>> +static int __vsock_deliver_tap_skb(struct sk_buff *skb,
>> +				     struct net_device *dev)
>> +{
>> +	int ret = 0;
>> +
>> +	if (skb) {
>> +		dev_hold(dev);
>> +		/* Take skb ownership so it is not consumed in dev_queue_xmit.
>> +		 * dev_queue_xmit will drop a reference so the reference count
>> +		 * will reset.
>> +		 */
>> +		skb_get(skb);
>
> Netlink clones the skb instead of adding a reference.  I guess this is
> because the skb might be modified later on?  Perhaps there are race
> conditions if the original skb is shared.
>

Seems that it is responsibility of the functions processing the skb to 
make sure that it is not modified (without performing a copy) if it is a 
shared skb, as it is the case. vsockmon doesn't modify it and from what 
I understand it is not modified along the tx path but, of course, I 
could be missing something.

As it is not performance critical it will be safer to just clone the skb 
so I'll do that.
