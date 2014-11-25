From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2] sh_eth: Fix sleeping function called from invalid
 context
Date: Tue, 25 Nov 2014 17:09:07 +0300
Message-ID: <54748D83.1090707@cogentembedded.com>
References: <1415862135-27972-1-git-send-email-ykaneko0929@gmail.com>	<1415862135-27972-2-git-send-email-ykaneko0929@gmail.com> <CAMuHMdWJYuXES4g1-=H6xo=gVePPSUkybUhL0VjuKk7asE6syg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:42618 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752408AbaKYOJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 09:09:11 -0500
Received: by mail-lb0-f169.google.com with SMTP id p9so592781lbv.28
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 06:09:09 -0800 (PST)
In-Reply-To: <CAMuHMdWJYuXES4g1-=H6xo=gVePPSUkybUhL0VjuKk7asE6syg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/25/2014 4:35 PM, Geert Uytterhoeven wrote:

>> From: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>

>> Fix the bug as follows:

>> ----
>> [ 1238.161349] BUG: sleeping function called from invalid context at drivers/base/power/runtime.c:952
>> [ 1238.188279] in_atomic(): 1, irqs_disabled(): 0, pid: 1388, name: cat
>> [ 1238.207425] CPU: 0 PID: 1388 Comm: cat Not tainted 3.10.31-ltsi-00046-gefa0b46 #1087
>> [ 1238.230737] Backtrace:
>> [ 1238.238123] [<c0012e64>] (dump_backtrace+0x0/0x10c) from [<c0013000>] (show_stack+0x18/0x1c)
>> [ 1238.263499]  r6:000003b8 r5:c06160c0 r4:c0669e00 r3:00404000
>> [ 1238.280583] [<c0012fe8>] (show_stack+0x0/0x1c) from [<c04515a4>] (dump_stack+0x20/0x28)
>> [ 1238.304631] [<c0451584>] (dump_stack+0x0/0x28) from [<c004970c>] (__might_sleep+0xf8/0x118)
>> [ 1238.329734] [<c0049614>] (__might_sleep+0x0/0x118) from [<c02465ac>] (__pm_runtime_resume+0x38/0x90)
>> [ 1238.357170]  r7:d616f000 r6:c049c458 r5:00000004 r4:d6a17210
>> [ 1238.374251] [<c0246574>] (__pm_runtime_resume+0x0/0x90) from [<c029b1c4>] (sh_eth_get_stats+0x44/0x280)
>> [ 1238.402468]  r7:d616f000 r6:c049c458 r5:d5c21000 r4:d5c21000
>> [ 1238.419552] [<c029b180>] (sh_eth_get_stats+0x0/0x280) from [<c03ae39c>] (dev_get_stats+0x54/0x88)
>> [ 1238.446204]  r5:d5c21000 r4:d5ed7e08
>> [ 1238.456980] [<c03ae348>] (dev_get_stats+0x0/0x88) from [<c03c677c>] (netstat_show.isra.15+0x54/0x9c)
>> [ 1238.484413]  r6:d5c21000 r5:d5c21238 r4:00000028 r3:00000001
>> [ 1238.501495] [<c03c6728>] (netstat_show.isra.15+0x0/0x9c) from [<c03c69b8>] (show_tx_errors+0x18/0x1c)
>> [ 1238.529196]  r7:d5f945d8 r6:d5f945c0 r5:c049716c r4:c0650e7c
>> [ 1238.546279] [<c03c69a0>] (show_tx_errors+0x0/0x1c) from [<c023963c>] (dev_attr_show+0x24/0x50)
>> [ 1238.572157] [<c0239618>] (dev_attr_show+0x0/0x50) from [<c010c148>] (sysfs_read_file+0xb0/0x140)
>> [ 1238.598554]  r5:c049716c r4:d5c21240
>> [ 1238.609326] [<c010c098>] (sysfs_read_file+0x0/0x140) from [<c00b9ee4>] (vfs_read+0xb0/0x13c)
>> [ 1238.634679] [<c00b9e34>] (vfs_read+0x0/0x13c) from [<c00ba0ac>] (SyS_read+0x44/0x74)
>> [ 1238.657944]  r8:bef45bf0 r7:00000000 r6:d6ac0600 r5:00000000 r4:00000000
>> [ 1238.678172] [<c00ba068>] (SyS_read+0x0/0x74) from [<c000eec0>] (ret_fast_syscall+0x0/0x30)
>> ----

>> Signed-off-by: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
>> ---
>>   drivers/net/ethernet/renesas/sh_eth.c | 64 +++++++++++++++++++----------------
>>   drivers/net/ethernet/renesas/sh_eth.h |  1 +
>>   2 files changed, 36 insertions(+), 29 deletions(-)

>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
>> index 60e9c2c..862a691 100644
>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
[...]
>> @@ -2131,6 +2133,36 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>>          return NETDEV_TX_OK;
>>   }
>>
>> +static struct net_device_stats *sh_eth_get_stats(struct net_device *ndev)
>> +{
>> +       struct sh_eth_private *mdp = netdev_priv(ndev);
>> +
>> +       if (sh_eth_is_rz_fast_ether(mdp))
>> +               return &ndev->stats;
>> +
>> +       if (!mdp->is_opened)

> Can't you use netif_running(ndev) instead?

    The __LINK_STATE_START flag it tests gets set in __dev_open() before 
calling the ndo_open() method. Looks like it would be somewhat unsafe to use it...

WBR, Sergei
