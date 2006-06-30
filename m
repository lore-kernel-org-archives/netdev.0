From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 15:43:38 +0200
Message-ID: <44A52A8A.2000507@6wind.com>
References: <20060628130124.GX1376@postel.suug.ch> <1151502408.5203.94.camel@jzny2> <20060629085111.GY1376@postel.suug.ch> <1151623394.8922.27.camel@jzny2> <20060629233933.GB14627@postel.suug.ch> <1151625826.8922.58.camel@jzny2> <20060630004640.GC14627@postel.suug.ch> <1151629890.8922.121.camel@jzny2> <20060630130811.GE14627@postel.suug.ch> <44A52435.20909@6wind.com> <20060630133658.GF14627@postel.suug.ch>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jamal <hadi@cyberus.ca>, Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:10258 "EHLO
	proxy.6wind.com") by vger.kernel.org with ESMTP id S1751001AbWF3Nnk
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 09:43:40 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060630133658.GF14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf a =E9crit :
> * Nicolas Dichtel <nicolas.dichtel@6wind.com> 2006-06-30 15:16
>>> That creates a nice loop on ingress. Upon reentering the
>>> stack with skb->dev set to eth0 again we'll go through the
>>> same ingress filters as the first time and we'll hit ifb0
>>> again over and over. Are you suggesting everyone has to
>>> insert a pass action matching input_dev in order to escape
>>> the loop when using ifb?
>> Bit 8 of skb->tc_verd is set by IFB, so packet isn't reclassify.
>> This bit avoid the loop.
>
> Right, my mistake. Just making classification impossible after
> going through an ifb device certainly seems like a perfect
> idea, nice!
Classification has already be done on the first pass. Mirror
action must be the last classifier.

Nicolas
