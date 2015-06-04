From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: [PATCH net-next 5/5] rocker: remove support for legacy VLAN ndo
 ops
Date: Thu, 04 Jun 2015 23:35:22 +0900
Message-ID: <5570622A.8000407@gmail.com>
References: <1433183947-13095-1-git-send-email-sfeldma@gmail.com> <1433183947-13095-6-git-send-email-sfeldma@gmail.com> <556D363A.5010005@lab.ntt.co.jp> <20150601.222442.1854333703599698362.davem@davemloft.net> <CAE4R7bBL+=-akoNLPqPae=zrYe3DH59t=8UK_T7KhcHSNaKUtw@mail.gmail.com> <556D96ED.9010309@mojatatu.com> <CAE4R7bAXA27cqBLv6MP0kak-L=1bXUoZPw7vxUyYpP=-dk=eAg@mail.gmail.com> <556DE0CD.9080000@cumulusnetworks.com> <CAE4R7bCPKcCYcHZ3WhkvjpioPhJP12Q35zRsq=t5gAO7JOZ94Q@mail.gmail.com> <556F209A.6090304@gmail.com> <alpine.DEB.2.02.1506032249390.46554@rocker1.rocker.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roopa <roopa@cumulusnetworks.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35536 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753197AbbFDOf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 10:35:26 -0400
Received: by padjw17 with SMTP id jw17so30884190pad.2
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 07:35:26 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1506032249390.46554@rocker1.rocker.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/06/04 (=E6=9C=A8) 15:05, Scott Feldman wrote:
> On Thu, 4 Jun 2015, Toshiaki Makita wrote:
>
>> Bridge's vlan_filtering is handled in master->op->foo(), not in
>> port->op->foo().
>> Can't we introduce another switchdev handler that performs MASTER
>> operation instead of calling SELF operation?
>>
>> br_afspec()
>> nbp_vlan_add()
>>  netdev_switch_port_vlan_add()
>>   rocker->ndo_switch_port_vlan_add() <- only used for MASTER operati=
on
>>
>> I'm wondering why SELF operation (rocker->ndo_bridge_setlink()) does
>> what should be done in MASTER operation.
>
> Something like this:

This looks very close to what I'm suggesting, although I'm not sure if
we need switchdev_port_obj_add() to be exclusive with vlan_vid_add().
=46or rocker, keeping NETIF_F_HW_VLAN_[CTAG/STAG]_FILTER dropped makes
vlan_vid_add() essentially noop.

Toshiaki Makita
