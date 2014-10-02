From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: macvlan: optimizing the receive path?
Date: Thu, 2 Oct 2014 14:31:36 -0700
Message-ID: <20141002143136.2234c9e6@urahara>
References: <542DB55D.3090601@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:50922 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751648AbaJBVbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 17:31:48 -0400
Received: by mail-pa0-f45.google.com with SMTP id rd3so2122pab.4
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 14:31:47 -0700 (PDT)
In-Reply-To: <542DB55D.3090601@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 02 Oct 2014 16:28:13 -0400
Jason Baron <jbaron@akamai.com> wrote:

> Hi,
> 
> I was just wondering why the netif_rx(skb) call in macvlan_handle_frame()
> was necessary? IE:


It is to prevent too deep a call stack of
  netif_receive_skb
     macvlan_receive
        netif_receive_skb ...
