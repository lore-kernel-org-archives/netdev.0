From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] IP_GRE: Fix IP-Identification.
Date: Thu, 21 Feb 2013 22:06:25 -0800
Message-ID: <1361513185.3683.1.camel@edumazet-glaptop>
References: <1361499519-1715-1-git-send-email-pshelar@nicira.com>
	 <1361500507.32484.8.camel@edumazet-glaptop>
	 <CALnjE+qOTnzdEjuGheRBhVC9piHdVKornV4Fv=ZubKS6ZAF6gQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jesse@nicira.com
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:49036 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752880Ab3BVGGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 01:06:35 -0500
Received: by mail-pb0-f45.google.com with SMTP id ro8so213592pbb.18
        for <netdev@vger.kernel.org>; Thu, 21 Feb 2013 22:06:35 -0800 (PST)
In-Reply-To: <CALnjE+qOTnzdEjuGheRBhVC9piHdVKornV4Fv=ZubKS6ZAF6gQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-21 at 19:42 -0800, Pravin Shelar wrote:

> Without this patch GRE-GSO generates ip fragments with id 0,2,3,4...
> for every GSO packet, which is not correct. This patch fixes it.
> --

I guess my question was more : Why dont we inherit ID from the inner
packet ?

ip_select_ident_more() is a performance killer, as all cpus are going to
access a shared counter in the dst.
