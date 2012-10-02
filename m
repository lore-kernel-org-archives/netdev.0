From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] iproute2: add support for tcp_metrics
Date: Tue, 02 Oct 2012 23:27:09 +0200
Message-ID: <1349213229.12401.1130.camel@edumazet-glaptop>
References: <1349210716-25509-1-git-send-email-ja@ssi.bg>
	 <1349211876.12401.1101.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:54073 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932335Ab2JBV1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 17:27:15 -0400
Received: by bkcjk13 with SMTP id jk13so5762654bkc.19
        for <netdev@vger.kernel.org>; Tue, 02 Oct 2012 14:27:14 -0700 (PDT)
In-Reply-To: <1349211876.12401.1101.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-02 at 23:04 +0200, Eric Dumazet wrote:
> On Tue, 2012-10-02 at 23:45 +0300, Julian Anastasov wrote:
> > 	ip tcp_metrics/tcpmetrics
> > 
> > 	We support get/del for single entry and dump for
> > show/flush.
> > 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > ---
> 
> Thanks Julian, this version works
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

By the way, it seems kernel exports scaled srtt by 8, and rttvar by 4.

And tcp_get_info() correctly exports us, not ms.

info->tcpi_rtt = jiffies_to_usecs(tp->srtt)>>3;
info->tcpi_rttvar = jiffies_to_usecs(tp->mdev)>>2;

IMHO we should use same unit than TCP_INFO (us for these values)
