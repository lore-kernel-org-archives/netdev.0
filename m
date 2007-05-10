From: "Yuriy N. Shkandybin" <jura@netams.com>
Subject: Re: [PATCH] vlan: lockdep subclass for ppp _xmit_lock Re: ppp_generic: fix lockdep warning
Date: Thu, 10 May 2007 10:03:23 +0400
Message-ID: <049301c792c8$ecdf4c40$0202fea9@Jura>
References: <200704260727.l3Q7RTxG023970@shell0.pdx.osdl.net> <20070426.013911.69219176.davem@davemloft.net> <20070426104950.GA3145@ff.dom.local> <20070509093536.GA2436@ff.dom.local> <001801c79275$80cd5e00$0701010a@note> <20070510053052.GA1611@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <akpm@linux-foundation.org>, <netdev@vger.kernel.org>,
	<paulus@samba.org>, <greearb@candelatech.com>,
	<mostrows@speakeasy.net>, <davem@davemloft.net>
To: "Jarek Poplawski" <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.netams.com ([212.192.245.10]:52049 "EHLO mail.netams.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752145AbXEJGDg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 02:03:36 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yes, there is no real lockup with pppoe
ll repeat my configuration:
vpn (pptp(mostly)+pppoe) concentrator
PPPoE provided through 802.1q
+OSPF (quagga)

Jura

----- Original Message ----- 
From: "Jarek Poplawski" <jarkao2@o2.pl>
To: "Yuriy N. Shkandybin" <jura@netams.com>
Cc: <akpm@linux-foundation.org>; <netdev@vger.kernel.org>; 
<paulus@samba.org>; <greearb@candelatech.com>; <mostrows@speakeasy.net>; 
<davem@davemloft.net>
Sent: Thursday, May 10, 2007 9:30 AM
Subject: Re: [PATCH] vlan: lockdep subclass for ppp _xmit_lock Re: 
ppp_generic: fix lockdep warning


> On Thu, May 10, 2007 at 12:06:09AM +0400, Yuriy N. Shkandybin wrote:
>> After applying this patch i've got this:
>>
>> =======================================================
>> [ INFO: possible circular locking dependency detected ]
>> 2.6.21-gentoo #2
>> -------------------------------------------------------
>> ospfd/3984 is trying to acquire lock:
>> (&ppp->wlock){-...}, at: [<ffffffff803512a0>] ppp_xmit_process+0x20/0x4f0
>>
>> but task is already holding lock:
>> (&dev->_xmit_lock){-+..}, at: [<ffffffff8038d778>] __qdisc_run+0x88/0x1c3
>>
>> which lock already depends on the new lock.
>
> Thanks Yuriy!
>
> As a matter of fact I suspected there will be something more.
> Lockdep always stops working after the first warning, and you
> have some very interesting (entangled) configuration, so each
> fix could uncover new warnings.
>
> I need some time to figure out this one, so I'd try to use your
> help yet... I hope it's only about lockdep warnings and there
> are no real lockups.
>
> Best regards,
> Jarek P.
> 

