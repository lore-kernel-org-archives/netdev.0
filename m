From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [PATCH] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Fri, 14 Jan 2011 14:56:55 +0800
Message-ID: <AANLkTinv4cYoExgYqCeSg61W1Rod_gywKuvyvbt42HMu@mail.gmail.com>
References: <1294919372-1904-1-git-send-email-ratbert.chuang@gmail.com> <1294928559.3570.130.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:58118 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752479Ab1ANG5R convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 01:57:17 -0500
In-Reply-To: <1294928559.3570.130.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Eric,

On Thu, Jan 13, 2011 at 10:22 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le jeudi 13 janvier 2011 =C3=A0 19:49 +0800, Po-Yu Chuang a =C3=A9cri=
t :
>> From: Po-Yu Chuang <ratbert@faraday-tech.com>
>>
>> FTMAC100 Ethernet Media Access Controller supports 10/100 Mbps and
>> MII. =C2=A0This driver has been working on some ARM/NDS32 SoC includ=
ing
>> Faraday A320 and Andes AG101.
>>
>> Signed-off-by: Po-Yu Chuang <ratbert@faraday-tech.com>
> Hi
>
> 1) please use netdev_alloc_skb_ip_align() instead of dev_alloc_skb() =
+
> skb_reserve(skb, NET_IP_ALIGN);

OK, fixed.

> 2) Dont include a "struct net_device_stats stats" in struct ftmac100,
> you can use the one included in struct net_device
> =C2=A0(You can then remove ftmac100_get_stats())

OK, fixed.

> 3) Dont "netdev->last_rx =3D jiffies;" : This is not driver job.
> =C2=A0Ditto for trans_start

OK, fixed.

> 4) You must comment why wmb() is needed in ftmac100_xmit()

OK, comment added.

> 5) Why isnt NAPI used too for TX completions ?
> =C2=A0 BTW, I am not sure we want a define. All new drivers must use =
NAPI.

I'll study how to do that

> 6) Use is_valid_ether_addr() instead of is_zero_ether_addr() in
> ftmac100_probe()

OK, fixed.

> 7) "static struct ethtool_ops ftmac100_ethtool_ops" should be const :
> =C2=A0 =C2=A0 =C2=A0 =C2=A0"static const struct ethtool_ops ftmac100_=
ethtool_ops"
> =C2=A0Ditto for :
> =C2=A0 =C2=A0 =C2=A0 =C2=A0"static struct net_device_ops ftmac100_net=
dev_ops"

OK, both fixed.

> 8) Why an interrupt handler (ftmac100_interrupt()) needs to block
> interrupts with spin_lock_irqsave(&priv->hw_lock, flags); ?

=46ixed. Not a problem anymore since hw_lock is removed now.

> 9) Instead of dev_info(&netdev->dev ...) , please consider netdev_inf=
o()

OK, fixed.


Thanks a lot for your detailed review. I'll submit a new version ASAP.

Thanks,
Po-Yu Chuang
