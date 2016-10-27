From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net 1/2] vxlan: avoid using stale vxlan socket.
Date: Thu, 27 Oct 2016 16:02:19 -0700
Message-ID: <20161027160219.06a946f4@xeon-e3>
References: <1477594316-118234-1-git-send-email-pshelar@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35226 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034052AbcJ0XCG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 19:02:06 -0400
Received: by mail-pf0-f169.google.com with SMTP id s8so25356624pfj.2
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 16:02:06 -0700 (PDT)
In-Reply-To: <1477594316-118234-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Oct 2016 11:51:55 -0700
Pravin B Shelar <pshelar@ovn.org> wrote:

> -	vxlan->vn4_sock = NULL;
> +	rcu_assign_pointer(vxlan->vn4_sock, NULL);
>  #if IS_ENABLED(CONFIG_IPV6)
> -	vxlan->vn6_sock = NULL;
> +	rcu_assign_pointer(vxlan->vn6_sock, NULL);
>  	if (ipv6 || metadata)

User RCU_INIT_POINTER when setting pointer to NULL.
It avoids unnecessary barrier.
