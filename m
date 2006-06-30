From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 15:20:42 +0200
Message-ID: <44A5252A.6070904@6wind.com>
References: <20060628101832.GW1376@postel.suug.ch> <1151497363.5203.47.camel@jzny2> <20060628130124.GX1376@postel.suug.ch> <1151502408.5203.94.camel@jzny2> <20060629085111.GY1376@postel.suug.ch> <1151623394.8922.27.camel@jzny2> <20060629233933.GB14627@postel.suug.ch> <1151625826.8922.58.camel@jzny2> <20060630004640.GC14627@postel.suug.ch> <1151629890.8922.121.camel@jzny2> <20060630130811.GE14627@postel.suug.ch>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:6151 "EHLO
	proxy.6wind.com") by vger.kernel.org with ESMTP id S932598AbWF3NUp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 09:20:45 -0400
Received: from [10.16.0.115] (unknown [10.16.0.115])
	by proxy.6wind.com (Postfix) with ESMTP id D53B3525F90
	for <netdev@vger.kernel.org>; Fri, 30 Jun 2006 15:20:43 +0200 (CEST)
To: netdev@vger.kernel.org
In-Reply-To: <20060630130811.GE14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf a =E9crit :
> * jamal <hadi@cyberus.ca> 2006-06-29 21:11
>> Heres what it would look at ingress:
>>
>> step 0: coming from wire via eth0,
>> dev=3Deth0, input_dev=3Deth0
>>
>> step 1: redirect to ifb0, leaving redirect
>> dev=3Difb0, input_dev=3Deth0
>>
>> step 2: leaving ifb0, coming back to ingress side of stack
>>
>> dev=3D eth0, input_dev=3Difb0
>
> That creates a nice loop on ingress. Upon reentering the
> stack with skb->dev set to eth0 again we'll go through the
> same ingress filters as the first time and we'll hit ifb0
> again over and over. Are you suggesting everyone has to
> insert a pass action matching input_dev in order to escape
> the loop when using ifb?
Bit 8 of skb->tc_verd is set by IFB, so packet isn't reclassify.
This bit avoid the loop.

Regards,
Nicolas
