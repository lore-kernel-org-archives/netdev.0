From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH: 2.6.13-15-SMP 3/3] network: concurrently run softirq
	network code on SMP
Date: Fri, 21 Sep 2007 07:43:43 -0400
Message-ID: <1190375023.4261.34.camel@localhost>
References: <002b01c7fb86$02b27df0$d6ddfea9@JOHNYE1>
	 <20070920.104614.58454013.davem@davemloft.net>
	 <00e601c7fc31$4ed29890$ca8510ac@asimco>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de
To: John Ye <johny@asimco.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.225]:5590 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755314AbXIULnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 07:43:49 -0400
Received: by wr-out-0506.google.com with SMTP id 36so323655wra
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 04:43:48 -0700 (PDT)
In-Reply-To: <00e601c7fc31$4ed29890$ca8510ac@asimco>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-21-09 at 17:25 +0800, John Ye wrote:
> David,
> 
> Thanks for your reply. I understand it's not worth to do.
> 
> I have made it a loadable module to fulfill the function. it mainly for busy
> NAT gateway server with SMP to speed up.
> 

John,

It was a little hard to read your code; however, it does seems to me
like will cause a massive amount of packet reordering to the end hosts
using you as the gateway especially when it is receiving a lot of
packets/second. 
You have a queue per CPU that connects your bottom and top half and
several CPUs that may service a single NIC in your bottom half.
one cpu in either bottom/top half has to be slightly loaded and you
loose the ordering where incoming doesnt match outgoing packet order. 

cheers,
jamal

