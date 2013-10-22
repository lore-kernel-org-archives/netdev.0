From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH stable 3.11] sit: amend "allow to use rtnl ops on fb
 tunnel"
Date: Tue, 22 Oct 2013 13:49:38 -0400 (EDT)
Message-ID: <20131022.134938.2214876943974242972.davem@davemloft.net>
References: <1382453958-32376-1-git-send-email-willemb@google.com>
	<20131022155627.GD25497@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, netdev@vger.kernel.org,
	nicolas.dichtel@6wind.com
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58378 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753392Ab3JVRtm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 13:49:42 -0400
In-Reply-To: <20131022155627.GD25497@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Tue, 22 Oct 2013 17:56:27 +0200

> On Tue, Oct 22, 2013 at 10:59:18AM -0400, Willem de Bruijn wrote:
>>Amend backport to 3.11.y of
>>
>> [ Upstream commit 205983c43700ac3a81e7625273a3fa83cd2759b5 ]
>>
>>The discussion thread in the upstream commit mentions that in
>>backports to stable-* branches, the line
>>
>>  - unregister_netdevice_queue(sitn->fb_tunnel_dev, &list);
>>
>>must be omitted if that branch does not have commit 5e6700b3bf98
>>("sit: add support of x-netns"). This line has correctly been omitted
>>in the backport to 3.10, which indeed does not have that commit.
>>
>>It was also removed in the backport to 3.11.y, which does have that
>>commit.
>>
>>This causes the following steps to hit a BUG at net/core/dev.c:5039:
>>
>>  `modprobe sit; rmmod sit`
>>
>>The bug demonstrates that it causes a device to be unregistered twice.
>>The simple fix is to apply the one line in the upstream commit that
>>was dropped in the backport to 3.11 (3783100374653e2e7fbdf68c710f5).
>>This brings the logic in line with upstream linux, net and net-next
>>branches.
> 
> Also seen that in stable, fixes it for me.
> 
> FWIW...
> 
> Reviewed-by: Veaceslav Falico <vfalico@redhat.com>
> 
>>
>>Signed-off-by: Willem de Bruijn <willemb@google.com>

I'll submit this to -stable, thanks everyone.
