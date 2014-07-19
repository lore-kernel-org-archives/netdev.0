From: Ethan Zhao <ethan.kernel@gmail.com>
Subject: Re: [PATCH V3] netxen: fix ethtool rx_dropped information in ethtool get_ethtool_stats()
Date: Sat, 19 Jul 2014 19:45:43 +0800
Message-ID: <CABawtvP4+B_smOyi-=vt56KuUthzHF9L059PXP4ekXA7KPk_Dw@mail.gmail.com>
References: <1405655009-18975-1-git-send-email-ethan.zhao@oracle.com>
	<C562D0E12CBDE44E8A0CCAB77060096701283AD344@AVMB1.qlogic.org>
	<049BCC6F-0A2E-421A-9873-0B7ED6FFB3AC@gmail.com>
	<20140719101946.GA4319@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Ethan Zhao <ethan.zhao@oracle.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140719101946.GA4319@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 19, 2014 at 6:19 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Ethan Zhao <ethan.kernel@gmail.com> :
>> ?? 2014??7??19????????2:21??Rajesh Borundia <rajesh.borundia@qlogic.com> ??????
> [...]
>> > I think ethtool stats are adapter specific. Driver does not maintain
>> > rx_dropped stats and we also don't get it from adapter.  I am not
>> > sure if ethtool stats should match ifconfig stats as ifconfig also
>> > adds net core stats to adapter stats.
>> I held the same point as yours before I read more drivers implementation
>> under Ethernet dir, in fact there is no specification/convention that
>> ethtool info is adapter specific. All information output by ethtool is
>> based on the information name itself, one fact we want this patch is
>> netxen defined 'rx dropped' field but output nothing.
>
> It may be fine as a requirement of the day but it does not bode well
> for the future as ethtool stats API won't get less messy.
 It is the fact.
>
> I'd rather see ethtool stats provides one of those:
> 1. hardware stats only
  Sounds very clear, is it done clear, if so we need other tools ?
  Then why net core increase dev->dropped like

  atomic_long_inc(&skb->dev->rx_dropped);

  and mess some of the info to dev. just let ifconfig report it without detail ?

> 2. driver dependent stats - anything you want - as long as the hardware
>    only part of the stats is clearly identified

  I agree with this point, there is no other interface let the driver
customizes the output of ethtool or ifconfig, ethtool is the only
interface to export information we want that is driver / device
related, even some of the information from net core where stack
information output not covered.

 Regard to dropped packets, some packets are to be dropped in net core without
error types reported. maybe it is why some drivers get rx dropped
stats from net core to avoid losing some of them.

>
> 2. needs works. 1. hurts any requirement where it would priviously had
> been so easy to add a few lines of code in the driver and push the mess
> straight from kernel to the end user application.

  Maybe some guys think that is enough to mess them together while not
identify the information from net core or driver. that is better than
lose info /no info.

 My case is user could be confused when run 'ifconfig' and 'ethtool'
to this netxen device. ifconfig reports packets dropped. but ethtool
says zero. does that mean it is not issue of driver forever ?  who
could tell where the packets are dropped, and for what ?

 So I would like the name of the data fields that ethtool output is be
better defined.
 Instead of saying is not covered by ethtool.

Thanks,
Ethan
>
> --
> Ueimor
