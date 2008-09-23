From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: Nagle latency tuning
Date: Tue, 23 Sep 2008 02:14:09 +0200
Message-ID: <20080923001409.GB25711@one.firstfloor.org>
References: <48D82378.4000306@redhat.com> <20080922.161323.108280715.davem@davemloft.net> <20080922232428.GA25711@one.firstfloor.org> <20080922.162158.223213897.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, csnook@redhat.com, rick.jones2@hp.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:56360 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330AbYIWAJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 20:09:19 -0400
Content-Disposition: inline
In-Reply-To: <20080922.162158.223213897.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> It is not an invalid estimate even in the NAT case, 

Typical case: you got a large company network behind a NAT.
First user has a very crappy wireless connection behind a slow
intercontinental link talking to the outgoing NAT router. He connectes to 
your internet server first and the window, slow start etc. parameters 
for him are saved in the dst_entry.  

The next guy behind the same NAT is in the same building
as the router who connects the company to the internet. He
has a much faster line. He connects to the same server. 
They will share the same dst and inetpeer entries.

The parameters saved earlier for the same IP are clearly invalid
for the second case. The link characteristics are completely 
different.

Also did you know there are there are whole countries behind
NAT. e.g. I was told that all of Saudi Arabia only comes from
a small handfull of IP addresses. It would surprise me if 
all of KSA has the same link characteristics? @)

Ah I see there's a sysctl now to disable this. How about
setting it by default?

-Andi
