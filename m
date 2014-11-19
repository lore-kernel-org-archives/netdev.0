From: Wengang <wen.gang.wang@oracle.com>
Subject: Re: [PATCH] bonding: clear header_ops when last slave detached (v2)
Date: Wed, 19 Nov 2014 15:00:50 +0800
Message-ID: <546C4022.5010509@oracle.com>
References: <1416374292-10993-1-git-send-email-wen.gang.wang@oracle.com> <1416375565.14060.43.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:24496 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932091AbaKSG71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 01:59:27 -0500
In-Reply-To: <1416375565.14060.43.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

=E4=BA=8E 2014=E5=B9=B411=E6=9C=8819=E6=97=A5 13:39, Eric Dumazet =E5=86=
=99=E9=81=93:
> On Wed, 2014-11-19 at 13:18 +0800, Wengang Wang wrote:
>> When last slave of a bonding master is removed, the bonding then doe=
s not work.
>> When packet_snd is called against with a master net_device, it acces=
ses
>> header_ops. In case the header_ops is not valid any longer(say ipoib=
 module
>> unloaded), it will then access an invalid memory address.
>> This patch try to fix this issue by clearing header_ops when last sl=
ave
>> detached.
>>
>> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
>> ---
>>   drivers/net/bonding/bond_main.c | 1 +
>>   1 file changed, 1 insertion(+)
> It seems you basically ignored my feedback.
>
>
>
> Some code is doing :
>
> [A] if (dev->header_ops) {
>      ...
> [B]    dev->header_ops->XXX()
>
>
>
> Nothing prevents you doing the clear after [A] , and before [B]
>

Yes, that's true. So the simplest way is move ipoib_header_ops to vmlin=
ux.

thanks for review.
wengang
