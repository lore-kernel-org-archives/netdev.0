From: Thomas Graf <tgraf@suug.ch>
Subject: Re: ProxyARP and IPSec
Date: Wed, 23 Aug 2006 21:14:25 +0200
Message-ID: <20060823191425.GK3470@postel.suug.ch>
References: <44EBA1FC.5000801@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:31383 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S965121AbWHWTOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 15:14:04 -0400
To: "H. Peter Anvin" <hpa@zytor.com>
Content-Disposition: inline
In-Reply-To: <44EBA1FC.5000801@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* H. Peter Anvin <hpa@zytor.com> 2006-08-22 17:31
> Specifically, Linux will not ProxyARP for an address unless it has a 
> route for it, *and* that route either has a DNAT marking or points to a 
> different interface than the input interface:

I can think of a very ugly way: Use netfilter to match on the
arp packet prerouting, set nfmark to some value, create a routing
rule matching the fwmark again, have it look up a separate table
with a dummy route pointing to a dummy device. Make sure to have
a proxy neighbour entry as using the device proxy_arp sysctl would
fail again.
