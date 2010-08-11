From: Brian Haley <brian.haley@hp.com>
Subject: Re: [iproute2] iproute2:  Fix 'addr flush secondary' logic.
Date: Wed, 11 Aug 2010 16:41:46 -0400
Message-ID: <4C630B0A.9010304@hp.com>
References: <1281547182-1252-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:17821 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758645Ab0HKUls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 16:41:48 -0400
In-Reply-To: <1281547182-1252-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/11/2010 01:19 PM, Ben Greear wrote:
> @@ -648,7 +648,7 @@ int print_addrinfo_secondary(const struct sockaddr_nl *who, struct nlmsghdr *n,
>  {
>  	struct ifaddrmsg *ifa = NLMSG_DATA(n);
>  
> -	if (ifa->ifa_flags & IFA_F_SECONDARY)
> +	if (!ifa->ifa_flags & IFA_F_SECONDARY)
>  		return 0;

Shouldn't this be:

	if (!(ifa->ifa_flags & IFA_F_SECONDARY))

-Brian
