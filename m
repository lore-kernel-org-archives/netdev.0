From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] Re: net, vxlan Fix compile warning
Date: Tue, 17 Sep 2013 21:26:21 +0100
Message-ID: <1379449581.1644.17.camel@bwh-desktop.uk.level5networks.com>
References: <20130916.212358.1356743853860170770.davem@davemloft.net>
	 <1379445167-28488-1-git-send-email-prarit@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <jpirko@redhat.com>,
	<davem@davemloft.net>, <stephen@networkplumber.org>
To: Prarit Bhargava <prarit@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:59346 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753336Ab3IQU00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 16:26:26 -0400
In-Reply-To: <1379445167-28488-1-git-send-email-prarit@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

You don't seem to have completed this change:

On Tue, 2013-09-17 at 15:12 -0400, Prarit Bhargava wrote:
[...]
> @@ -2291,9 +2289,9 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
>  	INIT_WORK(&vs->del_work, vxlan_del_work);
>  
>  	if (ipv6)
> -		rc = create_v6_sock(net, port, &sock);
> +		sock = create_v6_sock(net, port);
>  	else
> -		rc = create_v4_sock(net, port, &sock);
> +		sock = create_v4_sock(net, port);
>  	if (rc < 0) {

	if (IS_ERR(sock)) {

>  		kfree(vs);
>  		return ERR_PTR(rc);

		return ERR_CAST(sock);

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
