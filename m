From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: [PATCH] bridge: Fix br_should_learn to check vlan_enabled
Date: Tue, 16 Sep 2014 23:02:43 +0900
Message-ID: <54184303.9070503@gmail.com>
References: <1410809066-4434-1-git-send-email-vyasevic@redhat.com> <20140915.173849.609066505150727105.davem@davemloft.net> <541813AB.2060301@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, vyasevic@redhat.com
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	David Miller <davem@davemloft.net>, vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:41120 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753867AbaIPOCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 10:02:53 -0400
Received: by mail-pa0-f51.google.com with SMTP id kx10so8900178pab.24
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 07:02:53 -0700 (PDT)
In-Reply-To: <541813AB.2060301@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(14/09/16 (=E7=81=AB) 19:40), Toshiaki Makita wrote:
> On 2014/09/16 6:38, David Miller wrote:
>> From: Vladislav Yasevich <vyasevich@gmail.com>
>> Date: Mon, 15 Sep 2014 15:24:26 -0400
>>
>>> As Toshiaki Makita pointed out, the BRIDGE_INPUT_SKB_CB will
>>> not be initialized in br_should_learn() as that function
>>> is called only from br_handle_local_finish().  That is
>>> an input handler for link-local ethernet traffic so it perfectly
>>> correct to check br->vlan_enabled here.
>>>
>>> Reported-by: Toshiaki Makita<toshiaki.makita1@gmail.com>
>>> Fixes: 20adfa1 bridge: Check if vlan filtering is enabled only once=
=2E
>>> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
>>
>> Applied, thanks Vlad.
>
> Hi David,
>
> Could you queue this for -stable as well?
> Without this, FDB can be poisoned by disallowed ports.
> (the same problem as stated in e0d7968ab6c8 "bridge: Prevent insertio=
n
> of FDB entry with disallowed vlan")

I'm sorry, I was confusued.
This doesn't cause that problem, because if vlan_filtered is 0, fdb is=20
always updated with vid 0. Such an entry is never used as long as=20
vlan_filtering is enabled.
Please ignore my previous mail.

Thanks,
Toshiaki Makita
