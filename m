From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/8] flow_keys: Record IP layer protocol in
 skb_flow_dissect()
Date: Tue, 10 Jun 2014 07:26:30 -0700
Message-ID: <1402410390.3645.429.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1402338773-5996-1-git-send-email-_govind@gmx.com>
	 <1402338773-5996-2-git-send-email-_govind@gmx.com>
	 <539703F5.8030707@redhat.com> <alpine.LNX.2.03.1406101923050.2499@ws.cisco>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, ssujith@cisco.com, gvaradar@cisco.com,
	benve@cisco.com
To: Govindarajulu Varadarajan <_govind@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:37516 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbaFJO0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 10:26:32 -0400
Received: by mail-pd0-f174.google.com with SMTP id y10so269710pdj.33
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 07:26:31 -0700 (PDT)
In-Reply-To: <alpine.LNX.2.03.1406101923050.2499@ws.cisco>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-06-10 at 19:38 +0530, Govindarajulu Varadarajan wrote:
> 

> determining IPv4/IPv6 is important because this can be used in dissecting flow
> in Accelerated RFS. Adaptor does not support IPv6 filters. Since Accelerated
> RFS is supported for IPV6, using skb_flow_dissect will return true with non-zero
> values in src/dst for IPv6.
> 
> If I am going to write separate function for getting IP address and port
> numbers, its definition is going to be somewhat same as skb_flow_dissect.
> Why not improve whats already written and reuse it?
> 
> Is there any significant downside of adding u16 n_proto and increasing
> size of qdisc_skb_cb by 4 bytes?

You can avoid this increase (might be bad for IB, hard to tell), by
changing sch_choke.c to only store a part of the struct flow_keys.
