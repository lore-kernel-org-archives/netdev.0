From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: Re: question about nla_nest_cancel
Date: Thu, 27 Jan 2011 18:21:18 +0100
Message-ID: <20110127172118.GA331@e-circ.dyndns.org>
References: <Pine.LNX.4.64.1101271804530.13796@pc-004.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay002.isp.belgacom.be ([195.238.6.175]:63200 "EHLO
	mailrelay002.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751520Ab1A0RVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 12:21:20 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.1101271804530.13796@pc-004.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 27, 2011 at 06:08:34PM +0100, Julia Lawall wrote:
> 
> I find numerous occurrences of code like the following, in which nest ends 
> up with the value NULL and then nla_nest_cancel is called with nest as the 
> second argument.  But nla_nest_cancel just calls nlmsg_trim with the same 
> second argument, and nlmsg_trim does nothing if its second argument is 
> NULL.  Is there any reason to keep these calls?
I just learned this:
nla_nest_start() adds data to the skb.
nla_nest_end() 'commits' the proper length.
nla_nest_cancel() reverts skb to the state before nla_nest_start(),
as if nothing happened.

Kurt
