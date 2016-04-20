From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Tue, 19 Apr 2016 20:53:36 -0700
Message-ID: <5716FD40.7060408@cumulusnetworks.com>
References: <20160419.010316.1863885429013017239.davem@davemloft.net> <20160419.143134.2014460805657420897.davem@davemloft.net> <5716815C.6080601@cumulusnetworks.com> <20160419.184920.1193931883675948435.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, jhs@mojatatu.com,
	tgraf@suug.ch, nicolas.dichtel@6wind.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33970 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752325AbcDTDxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 23:53:39 -0400
Received: by mail-pa0-f43.google.com with SMTP id r5so12022892pag.1
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 20:53:38 -0700 (PDT)
In-Reply-To: <20160419.184920.1193931883675948435.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/19/16, 3:49 PM, David Miller wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> Date: Tue, 19 Apr 2016 12:05:00 -0700
>
>> ok, will do. one thing though, for GETSTATS, if I need a pad
>> attribute like IFLA_PAD, I will need to add a new stats attribute
>> IFLA_STATS_PAD and burn a bit for it in filter_mask too.  In which
>> case, I am wondering if we should live with the copy. I will take
>> any suggestions here.
> I don't think the copy is appropriate, especially if the existing full
> link state dump gets away without it.  We're adding this facility for
> performance reasons after all.
>
> You have several options to avoid wasting filter mask space. For
> example, you could use IFLA_STATS_UNSPEC, which should be OK since
> only new applications will use these.
>
> Or you could make IFLA_STATS_PAD the first attribute, and define the
> filter mask as relative to it.  Ie. IFLA_STATS_LINK_64 uses bit
> (IFLA_STATS_LINK_64 - IFLA_STATS_PAD), etc.
ok ack, makes sense.

thanks,
Roopa
