From: "Jerome Borsboom" <j.borsboom@erasmusmc.nl>
Subject: Re: [PATCH] parse ip:port strings correctly in in4_pton
Date: Mon, 16 Apr 2007 11:32:31 +0200
Message-ID: <46235ECF.12807.7C1F92@j.borsboom.erasmusmc.nl>
References: <Pine.LNX.4.64.0704161001280.1519@knorkaan.xs4all.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from knorkaan.xs4all.nl ([82.93.149.176]:49611 "EHLO
	knorkaan.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965153AbXDPJcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 05:32:39 -0400
In-reply-to: <46233E7C.10407@trash.net>
Content-description: Mail message body
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Jerome Borsboom wrote:
> > in4_pton converts a textual representation of an ip4 address into an
> > integer representation. However, when the textual representation is of
> > in the form ip:port, c.f. 192.168.1.1:5060, and 'delim' is set to -1,
> > the function bails out when parsing the colon.
> > 
> > It makes sense to allow the colon as a delimiting character without
> > explicitly having to set it through the 'delim' variable as there can be
> > no ambiguity in the point where the ip address is completely parsed.
> > Furthermore, this function is indeed called from nf_conntrack_sip.c in
> > this way to parse textual ip:port combinations which fails as stated above.
> 
> 
> What about IPv6? in6_pton behaves similar and is also used by
> nf_conntrack_sip.
> 

Don't think that in6_pton should be changed as a colon is the 
separator within the address. Maybe in6_pton should be changed to 
also parse IPv6 URI addresses of the form '[ipv6-addres]:port' which 
it currently cannot handle.
