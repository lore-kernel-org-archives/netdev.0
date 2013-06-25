From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: freeze with interface rename & SIOCGIFNAME
Date: Tue, 25 Jun 2013 10:19:37 -0700
Message-ID: <1372180777.3301.109.camel@edumazet-glaptop>
References: <51C9BB9C.4050405@freebox.fr>
	  <1372176951.3301.103.camel@edumazet-glaptop> <51C9C4FF.1020706@freebox.fr>
	  <1372179447.3301.105.camel@edumazet-glaptop>
	 <1372179933.3301.106.camel@edumazet-glaptop> <51C9CF8B.6030502@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: Nicolas Schichan <nschichan@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f172.google.com ([209.85.215.172]:64011 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751242Ab3FYRT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 13:19:29 -0400
Received: by mail-ea0-f172.google.com with SMTP id q10so7032053eaj.3
        for <netdev@vger.kernel.org>; Tue, 25 Jun 2013 10:19:28 -0700 (PDT)
In-Reply-To: <51C9CF8B.6030502@freebox.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-06-25 at 19:12 +0200, Nicolas Schichan wrote:

> Am I right in thinking that the process spinning on SIOCGIFNAME should be 
> naturally be preempted by other tasks by the scheduler once its timeslice has 
> expired or am I missing something ?

It depends on CONFIG_PREEMPT settings.

If the kernel is not preemptable, we basically can loop forever, unless
we call cond_resched()
