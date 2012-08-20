From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 1/2] ipv6: do not hold route table lock when send ndisc
 probe
Date: Mon, 20 Aug 2012 20:15:49 +0800
Message-ID: <1345464949.22373.14.camel@cr0>
References: <1345187499-16929-1-git-send-email-amwang@redhat.com>
	 <CAATkVEzKuTeUbU75B6EoSfFvGVsz_eK47XNWmsP5KcCvjTDEDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Banerjee, Debabrata" <dbanerje@akamai.com>,
	"David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Debabrata Banerjee <dbavatar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54461 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751823Ab2HTMQB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2012 08:16:01 -0400
In-Reply-To: <CAATkVEzKuTeUbU75B6EoSfFvGVsz_eK47XNWmsP5KcCvjTDEDA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-17 at 14:54 -0400, Debabrata Banerjee wrote:
> Well it get rids of the deadlock for sure, but I am not sure it
> doesn't break something else, one would have to know all of this code
> much better to tell. You'll notice read_unlock_bh(&table->tb6_lock)
> for the first lock in ip6_pol_route() has more in the critical section
> after the rt6_select() call, especially that rather scary BACKTRACK()
> macro.
> 

Yeah, I noticed that, ->tb6_lock seems to protect lookup of ->tb6_root,
not sure if 'rt' may still valid after retaking this lock... Hmm,
probably calling ndisc_send_ns() inside a work is a better approach.

I will update the patch.

Thanks!
