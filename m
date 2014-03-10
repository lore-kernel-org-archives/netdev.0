From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net-next: NULL pointer dereference on adding a net namespace
 and a system freeze
Date: Mon, 10 Mar 2014 06:44:29 -0700
Message-ID: <1394459069.3607.8.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140310014452.144b0491@north>
		 <1394424146.3607.2.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1394424557.3607.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <531D60EF.9000501@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <moorray3@wp.pl>, netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:64316 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753660AbaCJNob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 09:44:31 -0400
Received: by mail-pd0-f180.google.com with SMTP id v10so7115590pde.11
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 06:44:30 -0700 (PDT)
In-Reply-To: <531D60EF.9000501@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-10 at 14:51 +0800, Fan Du wrote:

> Sometimes network activity only on netns could trigger bugs like memory leakage,
> using per-netns kmem_cache could help to identify which netns to be blamed.
> 
> Anyway if this is inappropriate, let's make it global as you did below.

But you forgot to kmem_cache_destroy() the cache at netns removal, so
this also is a leak ;)
