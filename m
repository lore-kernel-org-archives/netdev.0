From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: Yet another bridge netfilter crash
Date: Tue, 10 Aug 2010 06:39:42 +0800
Message-ID: <AANLkTikpCOrkPqOkahXBFFoH6bqTKhA-+_mUy0qGrRnq@mail.gmail.com>
References: <20100723134208.GA6655@gondor.apana.org.au> <4C49A4C6.4070503@trash.net>
	<20100723150041.GA7301@gondor.apana.org.au> <4C49B296.10009@trash.net>
	<20100723152609.GA7576@gondor.apana.org.au> <4C5995C2.1010909@trash.net>
	<20100804164119.GA6256@gondor.apana.org.au> <4C599A6A.6050202@trash.net>
	<20100809214254.GA23824@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57434 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756103Ab0HIWkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 18:40:15 -0400
Received: by wyb32 with SMTP id 32so102489wyb.19
        for <netdev@vger.kernel.org>; Mon, 09 Aug 2010 15:40:13 -0700 (PDT)
In-Reply-To: <20100809214254.GA23824@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 10, 2010 at 5:42 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Wed, Aug 04, 2010 at 06:50:50PM +0200, Patrick McHardy wrote:
> .
>> >> Until we come up with something better the best fix seems to
>> >> be to perform the device lookup based on the iif.
>> >
>> > I don't think we can as the iif will point to the bridge device.
>> > The physindev contains the original physical device where the
>> > packet came in.
>>
>> If it originally points to the bridge device, there doesn't
>> seem anything wrong with the device pointing to the bridge
>> device after reassembly. Am I missing something?
>
> It's there so that netfilter rules can filter based on the original
> inbound interface.
>
> If you set it to the bridge then those rules won't work anymore.
>

How about always using the skb->nf_bridge of the skb last received in
a defrag queue as the nf_bridge of the final defraged skb? I have
posted a patch doing such thing.
http://patchwork.ozlabs.org/patch/60904/

Thanks.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
