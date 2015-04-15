From: George Dunlap <George.Dunlap@eu.citrix.com>
Subject: Re: [Xen-devel] [PATCH RFC] tcp: Allow sk_wmem_alloc to exceed sysctl_tcp_limit_output_bytes
Date: Wed, 15 Apr 2015 15:19:16 +0100
Message-ID: <CAFLBxZaDPa0Em6z-bwg1HoLqCU9R_rWD8ri+0sNVgX-Httj_1A@mail.gmail.com>
References: <1427388414-31077-1-git-send-email-jonathan.davies@citrix.com>
	<1427390070.25985.145.camel@edumazet-glaptop2.roam.corp.google.com>
	<551555E3.80205@citrix.com>
	<552BC899.8090300@citrix.com>
	<1428933925.3834.6.camel@edumazet-glaptop2.roam.corp.google.com>
	<552BDAC6.2020708@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Jonathan Davies <jonathan.davies@citrix.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev <netdev@vger.kernel.org>,
	James Morris <jmorris@namei.org>,
	"David S. Miller" <davem@davemloft.net>,
	xen-devel <xen-devel@lists.xenproject.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Patrick McHardy <kaber@trash.net>,
	Wei Liu <Wei.Liu2@citrix.com>
To: Malcolm Crossley <malcolm.crossley@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:35293 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753554AbbDOOTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 10:19:42 -0400
Received: by oign205 with SMTP id n205so24019616oig.2
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2015 07:19:41 -0700 (PDT)
In-Reply-To: <552BDAC6.2020708@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 13, 2015 at 4:03 PM, Malcolm Crossley
<malcolm.crossley@citrix.com> wrote:
>>
>> But the main concern here is it basically breaks back pressure.
>>
>> And you do not want this, unless there is no other choice.
>>
>
> virtio_net already use's skb_orphan() in it's transmit path. It seems
> only fair that other virtual network drivers behave in the same way.
>
> There are no easy solutions to decrease the transmit latency for
> netback/netfront. We map the guest memory through to the backend to
> avoid memory copies. The frontend memory can only be freed once the
> network driver has completed transmitting the packet in the backend.
>
> Modern network drivers can be quite slow at freeing the skb's once
> transmitted (the packet is already on the wire as far as they are
> concerned) and this delay is compounded by needing the signal the
> completion of the transmit back to the frontend (by IPI in worst case).
>
> From a networking point of view, the backend is a switch. Is it OK to
> consider the packet to have been transmitted from the guest point of
> view once the backend is aware of the packet?
>
> This would help justify the skb_orphan() in the frontend.

This sounds sensible to me, particularly if virtio_net is already doing it.

 -George
