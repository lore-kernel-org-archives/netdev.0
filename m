From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2] net: l3mdev: Add master device lookup by
 index
Date: Sun, 22 Nov 2015 10:30:32 -0700
Message-ID: <5651FBB8.6030008@cumulusnetworks.com>
References: <1447965121-2345-1-git-send-email-dsa@cumulusnetworks.com>
 <20151122.122359.2247708943529789130.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33607 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825AbbKVRag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2015 12:30:36 -0500
Received: by pabfh17 with SMTP id fh17so172480287pab.0
        for <netdev@vger.kernel.org>; Sun, 22 Nov 2015 09:30:36 -0800 (PST)
In-Reply-To: <20151122.122359.2247708943529789130.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/22/15 10:23 AM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Thu, 19 Nov 2015 12:32:00 -0800
>
>> Add helper to lookup master index given a device index.
>>
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>
> I don't like where this is going.
>
> sk->sk_bound_dev_if is for device bindings which the user has
> explicitly asked for.
>
> We should never, therefore, automatically set it without the user's
> consent.

In this case the user is running a daemon (bgpd) where a single instance 
works across all VRFs. The listen socket is not bound to a device, so 
this does not override what the user ask for. Child sockets are then 
bound to the VRF device the connection originates over, so it narrows 
the scope of accepted connections to a single VRF.

If you look at the change, e.g.,:

     ireq->ir_iif = sk->sk_bound_dev_if ? : 
l3mdev_master_ifindex_by_index(sock_net(sk), skb->skb_iif);

It keeps user requested sk_bound_dev_if if it is set. If not, applies 
the limited scope of a VRF device if the skb originated on a device 
enslaved to a VRF device.
