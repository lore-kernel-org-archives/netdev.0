From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] socket: increase default maximum listen queue length
Date: Sun, 20 Mar 2011 12:39:21 +0100
Message-ID: <20110320113921.GA3038@nuttenaction>
References: <1300585811-21566-1-git-send-email-hagen@jauu.net>
 <1300609817.2831.56.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:58184 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751877Ab1CTLjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2011 07:39:24 -0400
Content-Disposition: inline
In-Reply-To: <1300609817.2831.56.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet | 2011-03-20 09:30:17 [+0100]:

>Hmm, real problem is not the 'maximum queue value', but the minimum one.
>
>If application says : listen(fd, 10), you are stuck.
>
>128 or 256 is way too small on some servers, where admin can tune
>in /etc/sysctl.conf :
>
>net.core.somaxconn = 8192
>net.ipv4.tcp_max_syn_backlog = 8192
>
>But application also needs to use : listen(fd, 8192)

I know Eric, I wrote the patch. ;-) The used naming goes like this:

The system limits (somaxconn & tcp_max_syn_backlog) specify a _maximum_, the
user cannot exceed this limit with listen(2). The backlog argument for listen
on the other hand specify a _minimum_. But the patch increased the default
maximum, therefore I named it in this way.
