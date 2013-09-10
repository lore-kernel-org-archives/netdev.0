From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] net: sctp: fix ipv6 ipsec encryption bug in sctp_v6_xmit
Date: Tue, 10 Sep 2013 21:08:41 +0200
Message-ID: <522F6E39.1050305@redhat.com>
References: <1378836316-17503-1-git-send-email-dborkman@redhat.com> <522F6BDD.3050309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, adobriyan@gmail.com,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64834 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750905Ab3IJTJA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Sep 2013 15:09:00 -0400
In-Reply-To: <522F6BDD.3050309@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/10/2013 08:58 PM, Vlad Yasevich wrote:
[...]
> I don't think this is actually the correct thing to do.
> 1) Every transmit has a possibility of changing np and thus changing
> the result of getsockname() and getpeername()
> 2) You will end up with a route lookup on every packet since np->dst_cookie is not set properly.
>
> I wonder if it would solve things if you simply pass the flowi cached in the transport to ip6_xmit().
>
> If not, then probably sctp_v6_get_dst() needs to be updated to find the
> correct route, so then it can be cached in the transport along with the
> flowi and used on output.

Ok, let me have a look at these alternatives tomorrow first thing in the
morning, and I'll respin.

Thanks,
Daniel
