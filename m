From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: 8139cp: set ring address before enabling receiver
Date: Wed, 21 Nov 2012 13:12:02 -0500
Message-ID: <50AD1972.5080403@pobox.com>
References: <20120602235020.2C0A57C006C@ra.kernel.org> <1353517042.26346.130.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:53168 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755353Ab2KUSMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 13:12:09 -0500
Received: by mail-vc0-f174.google.com with SMTP id m18so3828498vcm.19
        for <netdev@vger.kernel.org>; Wed, 21 Nov 2012 10:12:08 -0800 (PST)
In-Reply-To: <1353517042.26346.130.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21/2012 11:57 AM, David Woodhouse wrote:
> On Sat, 2012-06-02 at 23:50 +0000, Linux Kernel Mailing List wrote:
>> Gitweb:     http://git.kernel.org/linus/;a=commit;h=b01af4579ec41f48e9b9c774e70bd6474ad210db
>> Commit:     b01af4579ec41f48e9b9c774e70bd6474ad210db
>> Parent:     20e2a86485967c385d7c7befc1646e4d1d39362e
>> Author:     Jason Wang <jasowang@redhat.com>
>> AuthorDate: Thu May 31 18:19:39 2012 +0000
>> Committer:  David S. Miller <davem@davemloft.net>
>> CommitDate: Fri Jun 1 14:22:11 2012 -0400
>>
>>      8139cp: set ring address before enabling receiver
>>
>>      Currently, we enable the receiver before setting the ring address which could
>>      lead the card DMA into unexpected areas. Solving this by set the ring address
>>      before enabling the receiver.
>>
>>      btw. I find and test this in qemu as I didn't have a 8139cp card in hand. please
>>      review it carefully.

What sticks out at me from the commit message?

It was not tested on the famously quirky 8139 hardware at all.

While I have not looked at the 8139C+ data sheet in a while, sometimes 
the hardware _did_ have a strange init order.

As this works in a simulator but fails on real hardware, it seems like 
an obvious regression caused by an untested [on read hardware] patch.

	Jeff
