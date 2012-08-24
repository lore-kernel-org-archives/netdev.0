From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] ipv6: do not hold route table lock when send ndisc
 probe
Date: Fri, 24 Aug 2012 11:44:44 +0200
Message-ID: <1345801484.29722.2.camel@edumazet-glaptop>
References: <1345187499-16929-1-git-send-email-amwang@redhat.com>
	 <CAATkVEzKuTeUbU75B6EoSfFvGVsz_eK47XNWmsP5KcCvjTDEDA@mail.gmail.com>
	 <1345520643.12468.6.camel@cr0>
	 <1345738232.5904.1244.camel@edumazet-glaptop>
	 <1345799724.11584.15.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Debabrata Banerjee <dbavatar@gmail.com>, netdev@vger.kernel.org,
	"Banerjee, Debabrata" <dbanerje@akamai.com>,
	"David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:47691 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754493Ab2HXJoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 05:44:54 -0400
Received: by bkwj10 with SMTP id j10so519681bkw.19
        for <netdev@vger.kernel.org>; Fri, 24 Aug 2012 02:44:53 -0700 (PDT)
In-Reply-To: <1345799724.11584.15.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-24 at 17:15 +0800, Cong Wang wrote:

> 
> Right... If we call dev_hold() in the work, it is possible that the work
> is still not scheduled to running when we unregister the device. What's
> more, we can't flush work here as we are holding a read lock.

You need a global list (and a single work, not one per req), so that a
notifier can flush it at demand.
