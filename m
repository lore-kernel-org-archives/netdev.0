From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip-address: properly display zero IPv4 peer
 address
Date: Mon, 23 Nov 2015 16:04:50 -0800
Message-ID: <20151123160450.73eec3ef@xeon-e3>
References: <1445502868-29474-1-git-send-email-thaller@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Thomas Haller <thaller@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33476 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751812AbbKXAEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 19:04:41 -0500
Received: by pabfh17 with SMTP id fh17so870816pab.0
        for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 16:04:40 -0800 (PST)
In-Reply-To: <1445502868-29474-1-git-send-email-thaller@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 Oct 2015 10:34:28 +0200
Thomas Haller <thaller@redhat.com> wrote:

> Kernel allows for zero IPv4 peer addresses (IFA_ADDRESS):
> 
>    ip address add 192.168.5.1 peer 0.0.0.0/24 dev dummy
> 
> which is distinct from a usual address like:
> 
>    ip address add 192.168.5.1/24 dev dummy
>    ip address add 192.168.5.1 peer 192.168.5.1/24 dev dummy
> 
> For IPv4, a missing IFA_ADDRESS attribute means that the peer
> is 0.0.0.0. See inet_fill_ifaddr(), which does:
> 
>   if ((ifa->ifa_address &&
>        nla_put_in_addr(skb, IFA_ADDRESS, ifa->ifa_address)) ||
> 
> Signed-off-by: Thomas Haller <thaller@redhat.com>

I would prefer that this apply to both IPv4 and IPv6.
If the kernel sends back an address, then display it.
