From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] iproute2 flush: handle larger tables and deleted entries
Date: Tue, 14 Jul 2009 11:38:59 +0200
Message-ID: <4A5C5233.4010007@trash.net>
References: <4e0db5bc0907130939k48b16256j8f60c786a7e5e44c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Gautam Kachroo <gk@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46156 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753867AbZGNJjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 05:39:07 -0400
In-Reply-To: <4e0db5bc0907130939k48b16256j8f60c786a7e5e44c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gautam Kachroo wrote:
> use a new netlink socket when sending flush messages to avoid reading
> any pending data on the existing netlink socket.
> 
> read all of the response from the netlink request -- this response can
> be split over multiple recv calls, pretty much one per netlink request
> message. ENOENT errors, which correspond to attempts to delete an
> already deleted entry, are ignored. Other errors are not ignored.

In which case would there be any pending data? From what I can see,
this can only happen when using batching, but in that case the
previous command should continue reading until it has received all
responses (which the netlink functions appear to be doing properly).

