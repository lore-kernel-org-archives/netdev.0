From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next RFC v2 2/3] ipv4: add support for light weight
 tunnel encap attributes
Date: Sun, 21 Jun 2015 22:20:17 +0200
Message-ID: <20150621202017.GA4228@pox.localdomain>
References: <1434689355-4088-3-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ebiederm@xmission.com, rshearma@brocade.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:33536 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751186AbbFUUUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 16:20:22 -0400
Received: by wgwi7 with SMTP id i7so6334669wgw.0
        for <netdev@vger.kernel.org>; Sun, 21 Jun 2015 13:20:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1434689355-4088-3-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/18/15 at 09:49pm, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> Introduces two netlink attributes RTA_ENCAP_TYPE and
> RTA_ENCAP to support attaching encap information to ipv4 routes.
> 
> RTA_ENCAP is a nested attribute as suggested by Thomas
> (and also as Robert had it in his series). RTA_ENCAP
> netlink policy is declared by the light weight tunnel
> drivers that support this encap type.
> 
> fib code calls the following for each nexthop:
> 	- new route handler:
> 		lwt build state (that parses RTA_ENCAP and returns
> 	  	lwt state that lives in every fib_nh)
> 	- del dump hanlder:
> 		lwt release handler to release lwt state data
> 	- route dump hanlder:
> 		lwt dump encap to fill RTA_ENCAP data
> 	- during input route lookup
> 		sets dst->output to lwtunnel_output which
> 		in turn calls the corresponding lwt tunnel
> 		output function which applies the required
> 		encap and xmits the packet

Thanks for putting in the flag! I think introducing helpers for the
lwt work would help as it can centralize the required ifdef magic
and be defined as a static inline nop or macros so the core routing
code doesn't need to have ifdefs spread around.
