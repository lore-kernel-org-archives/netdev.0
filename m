From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net/core: fix for_each_netdev_feature
Date: Tue, 3 Nov 2015 16:33:38 +0100
Message-ID: <5638D3D2.5080703@cumulusnetworks.com>
References: <1446519359-21400-1-git-send-email-jarod@redhat.com>
 <1446563759-17713-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	Michal Kubecek <mkubecek@suse.cz>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	netdev@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:36732 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030AbbKCPdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 10:33:47 -0500
Received: by wmec75 with SMTP id c75so89653953wme.1
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 07:33:46 -0800 (PST)
In-Reply-To: <1446563759-17713-1-git-send-email-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/03/2015 04:15 PM, Jarod Wilson wrote:
> As pointed out by Nikolay and further explained by Geert, the initial
> for_each_netdev_feature macro was broken, as feature would get set outside
> of the block of code it was intended to run in, thus only ever working for
> the first feature bit in the mask. While less pretty this way, this is
> tested and confirmed functional with multiple feature bits set in
> NETIF_F_UPPER_DISABLES.
> 
> [root@dell-per730-01 ~]# ethtool -K bond0 lro off
> ...
> [  242.761394] bond0: Disabling feature 0x0000000000008000 on lower dev p5p2.
> [  243.552178] bnx2x 0000:06:00.1 p5p2: using MSI-X  IRQs: sp 74  fp[0] 76 ... fp[7] 83
> [  244.353978] bond0: Disabling feature 0x0000000000008000 on lower dev p5p1.
> [  245.147420] bnx2x 0000:06:00.0 p5p1: using MSI-X  IRQs: sp 62  fp[0] 64 ... fp[7] 71
> 
> [root@dell-per730-01 ~]# ethtool -K bond0 gro off
> ...
> [  251.925645] bond0: Disabling feature 0x0000000000004000 on lower dev p5p2.
> [  252.713693] bnx2x 0000:06:00.1 p5p2: using MSI-X  IRQs: sp 74  fp[0] 76 ... fp[7] 83
> [  253.499085] bond0: Disabling feature 0x0000000000004000 on lower dev p5p1.
> [  254.290922] bnx2x 0000:06:00.0 p5p1: using MSI-X  IRQs: sp 62  fp[0] 64 ... fp[7] 71
> 
> Fixes: fd867d51f ("net/core: generic support for disabling netdev features down stack")
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Eric Dumazet <edumazet@google.com>
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Veaceslav Falico <vfalico@gmail.com>
> CC: Andy Gospodarek <gospo@cumulusnetworks.com>
> CC: Jiri Pirko <jiri@resnulli.us>
> CC: Nikolay Aleksandrov <razor@blackwall.org>
> CC: Michal Kubecek <mkubecek@suse.cz>
> CC: Alexander Duyck <alexander.duyck@gmail.com>
> CC: Geert Uytterhoeven <geert@linux-m68k.org>
> CC: netdev@vger.kernel.org
> Signed-off-by: Jarod Wilson <jarod@redhat.com>
> ---
>  include/linux/netdev_features.h | 6 ++----
>  net/core/dev.c                  | 8 ++++++--
>  2 files changed, 8 insertions(+), 6 deletions(-)
> 

Looks good to me especially without the hidden side-effects,

Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Thanks,
 Nik
