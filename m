From: Ceriel Jacobs <linux-ide@crashplan.pro>
Subject: Re: r8168 is needed to enter P-state: Package State 6 (pc6)onHaswell
 hardware: does the patch below against current kernel make a difference?
Date: Thu, 09 Oct 2014 00:46:27 +0200
Message-ID: <5435BEC3.6080200@crashplan.pro>
References: <542B3829.3010108@crashplan.pro> <20141005165920.GA21926@electric-eye.fr.zoreil.com> <0835B3720019904CB8F7AA43166CEEB2526932@RTITMBSV03.realtek.com.tw> <20141006221307.GB10936@electric-eye.fr.zoreil.com> <54359E9C.7060704@crashplan.pro> <20141008221726.GA25515@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hayes Wang <hayeswang@realtek.com>,
	nic_swsd <nic_swsd@realtek.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:45490 "EHLO
	relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750946AbaJHWqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 18:46:34 -0400
In-Reply-To: <20141008221726.GA25515@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 3.13 source was installed using "apt-get source linux-source-3.13.0"

The patch hunk#2 failing issue is something in the "heredoc" notation 
(me trying to apply the patch without storing the patch lines as 
temporary input file). I am now using the temp file without any issue.

The next newly blocking issue is this:

# make -C /lib/modules/$(uname -r)/build M=$(pwd) modules
make: Entering directory `/usr/src/linux-headers-3.17.0-031700rc7-generic'
   CC [M]  /root/linux-3.13.0/drivers/net/ethernet/realtek/8139cp.o
   CC [M]  /root/linux-3.13.0/drivers/net/ethernet/realtek/8139too.o
   CC [M]  /root/linux-3.13.0/drivers/net/ethernet/realtek/atp.o
   CC [M]  /root/linux-3.13.0/drivers/net/ethernet/realtek/r8169.o
/root/linux-3.13.0/drivers/net/ethernet/realtek/r8169.c: In function 
'rtl_init_one':
/root/linux-3.13.0/drivers/net/ethernet/realtek/r8169.c:7127:2: error: 
implicit declaration of function 'SET_ETHTOOL_OPS' 
[-Werror=implicit-function-declaration]
   SET_ETHTOOL_OPS(dev, &rtl8169_ethtool_ops);
   ^
cc1: some warnings being treated as errors
make[1]: *** [/root/linux-3.13.0/drivers/net/ethernet/realtek/r8169.o] 
Error 1
make: *** [_module_/root/linux-3.13.0/drivers/net/ethernet/realtek] Error 2
make: Leaving directory `/usr/src/linux-headers-3.17.0-031700rc7-generic'

Any new suggestion how to honour your patch/test request?

Francois Romieu schreef op 09-10-14 om 00:17:
> Ceriel Jacobs <linux-ide@crashplan.pro> :
> [...]
>> Francois, could you help me apply your patch?
>
> $ git describe
> v3.13
> $ patch -p1 --dry-run < /tmp/plop
> checking file drivers/net/ethernet/realtek/r8169.c
> Hunk #1 succeeded at 467 (offset -1 lines).
> Hunk #2 succeeded at 5275 (offset -5 lines).
>
> $ git rev-list v3.16 -- drivers/net/ethernet/realtek/r8169.c | while read x; do echo $x:$(git cat-file -p $x:drivers/net/ethernet/realtek/r8169.c | md5sum); done | grep 95056b56932b375f8b65a6379009f704
>
> -> oualou
>
> Where does your 3.13 source tree come from ?
>
