From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH] bridge: Fix br_should_learn to check vlan_enabled
Date: Tue, 16 Sep 2014 19:40:43 +0900
Message-ID: <541813AB.2060301@lab.ntt.co.jp>
References: <1410809066-4434-1-git-send-email-vyasevic@redhat.com> <20140915.173849.609066505150727105.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, toshiaki.makita1@gmail.com,
	vyasevic@redhat.com
To: David Miller <davem@davemloft.net>, vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:55917 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753787AbaIPKk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 06:40:56 -0400
In-Reply-To: <20140915.173849.609066505150727105.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/09/16 6:38, David Miller wrote:
> From: Vladislav Yasevich <vyasevich@gmail.com>
> Date: Mon, 15 Sep 2014 15:24:26 -0400
> 
>> As Toshiaki Makita pointed out, the BRIDGE_INPUT_SKB_CB will
>> not be initialized in br_should_learn() as that function
>> is called only from br_handle_local_finish().  That is
>> an input handler for link-local ethernet traffic so it perfectly
>> correct to check br->vlan_enabled here.
>>
>> Reported-by: Toshiaki Makita<toshiaki.makita1@gmail.com>
>> Fixes: 20adfa1 bridge: Check if vlan filtering is enabled only once.
>> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> 
> Applied, thanks Vlad.

Hi David,

Could you queue this for -stable as well?
Without this, FDB can be poisoned by disallowed ports.
(the same problem as stated in e0d7968ab6c8 "bridge: Prevent insertion
of FDB entry with disallowed vlan")

Thanks,
Toshiaki Makita
