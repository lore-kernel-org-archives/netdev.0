From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4 net-2.6.26] [IPV4]: Cleanup ip_options_compile.
Date: Mon, 03 Mar 2008 15:02:14 -0800 (PST)
Message-ID: <20080303.150214.42261005.davem@davemloft.net>
References: <1204577698.23504.13.camel@iris.sw.ru>
	<20080303.132422.64941146.davem@davemloft.net>
	<1204585051.23504.35.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55346
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754710AbYCCXC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 18:02:29 -0500
In-Reply-To: <1204585051.23504.35.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Tue, 04 Mar 2008 01:57:31 +0300

> On Mon, 2008-03-03 at 13:24 -0800, David Miller wrote:
> > I suppose it gets used by ip_options_build() for outgoing
> > packets, which assumes that is_data is always set?
> 
> is_data is checked in the only place in the code, in the
> ip_options_compile. It, in turn is called twice in the original code:
> 
> ip_options_get_finish
>         opt->is_data = 1;    <-- !!!
>         if (optlen && ip_options_compile(opt, NULL))
> 
> ip_rcv_options
>    if (ip_options_compile(NULL, skb)) {
> 
> So, (opt && !opt->is_data) is impossible in the orignal code where it is
> checked.

Ok, fixup the cipso build failure and resubmit.

Thanks.
