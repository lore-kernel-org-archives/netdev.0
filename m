From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: atl1 warn_on_slowpath help
Date: Wed, 29 Oct 2008 13:22:43 +0000
Message-ID: <20081029132243.GB7256@ff.dom.local>
References: <20081029071549.GA4861@ff.dom.local> <49081AE4.9040301@trash.net> <49083825.3000601@trash.net> <20081029130313.GA7256@ff.dom.local> <49086074.3080208@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Cliburn <jcliburn@gmail.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:25847 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752945AbYJ2NWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 09:22:50 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1264065nfc.21
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 06:22:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <49086074.3080208@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 29, 2008 at 02:09:08PM +0100, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> On Wed, Oct 29, 2008 at 11:17:09AM +0100, Patrick McHardy wrote:
>>> The __vlan_hwaccel_rx function only does the device lookup and
>>> stores it in the cb. The remaining processing is done in a new
>>> function that is invoked by netif_receive_skb(), in the proper
>>> context. Unfortunatly this needs vlan-specific handling in
>>> netif_receive_skb().
>>>
>>
>> Unfortunately I'm not up-to-date with vlans and especially this
>> nit_deliver problem, but here is a little doubt: since this is
>> probably for stable, and skb->cb is rather tricky, I wonder why
>> vlan_group_get_device() couldn't be used directly in
>> vlan_hwaccel_do_receive()?
>
> Because it needs the VLAN group, and that has to be passed
> around somehow (=> skb->cb). So we might as well look up the
> device immediately.

Sure! I've missed this little detail...

>
> Its trivial to verify that the use of skb->cb is fine, the
> only codepath besides the one leading to vlan_hwaccel_do_receive
> immediately is through netif_rx.
>
>> BTW: if we call netif_nit_deliver() from vlan_hwaccel_do_receive()
>> from netif_receive_skb() this comment about bypassing looks a bit
>> confusing to me:
>>
>> /*
>>  *     netif_nit_deliver - deliver received packets to network taps
>>  *     @skb: buffer
>>  *
>>  *     This function is used to deliver incoming packets to network
>>  *     taps. It should be used when the normal netif_receive_skb path
>>  *     is bypassed, for example because of VLAN acceleration.
>>  */
>
> Agreed, this could be improved.
>
>> As a matter of fact without this patch it's not so apparent why
>> netif_receive_skb() can't happen after netif_nit_deliver() in
>> __vlan_hwaccel_rx() too.
>
> I don't understand what you're saying.

It's still about this bypassing: netif_receive_skb() can be called
after netif_nit_deliver().

Thanks,
Jarek P.
