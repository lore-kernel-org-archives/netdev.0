From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] net: Check skb->rxhash in gro_receive
Date: Fri, 10 Jan 2014 11:42:12 -0800
Message-ID: <CA+mtBx-OHxHCTQO50F9_aw=T8VSg93E2eCkzdLL3PZapcR-CFQ@mail.gmail.com>
References: <alpine.DEB.2.02.1401092051020.25554@tomh.mtv.corp.google.com>
	<1389332287.31367.88.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+mtBx_c=we-13b0Vyrim0=kArhx0OYY1P99HwUeuR2w87hRFw@mail.gmail.com>
	<1389375935.31367.102.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+mtBx-8=tiYw=-_TydO0bC_tJXK6MqxjnZQaCXqUtxLSF7xhQ@mail.gmail.com>
	<1389380077.31367.114.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:51448 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235AbaAJTmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 14:42:12 -0500
Received: by mail-ie0-f181.google.com with SMTP id e14so5693828iej.40
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 11:42:12 -0800 (PST)
In-Reply-To: <1389380077.31367.114.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Really, 99% of the time gro_list contains zero or one single slot, I
> have hard data saying so.
>
Please provide the data.

> If you want to optimize the case where list is fully populated (because
> of yet another synthetic benchmark you use), you really need to build a
> temporary list so that all layers do not even have to check
> NAPI_GRO_CB(p)->same_flow
>
Well if you prefer, you can think of the "synthetic benchmark" as
emulating an obvious DOS attack by pumping MSS sized TCP segments with
random ports to a server. The stack needs to be resilient to such
things, an O(n*m) algorithm in the data path is a red flag.

> Each gro handler would remove non matching flow from this temp list.
>
> -> when we finally reach tcp_gro_receive(), list would contain a single
> element.
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
