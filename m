From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] openvswitch: adjust skb_gso_segment() for rx
 path
Date: Fri, 01 Feb 2013 10:09:04 +0800
Message-ID: <1359684544.22074.6.camel@cr0>
References: <1359535089-18348-1-git-send-email-amwang@redhat.com>
	 <CAEP_g=-pdossS=kAVzQMuvTnKU-Sg9PvskiocqcxdsBDtbvdCw@mail.gmail.com>
	 <1359596906.29117.9.camel@cr0>
	 <CAEP_g=9JqFi7apps-aDqxuGck-hYSvaUT6pzXR-gDkAvLovS8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36153 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752680Ab3BACJT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2013 21:09:19 -0500
In-Reply-To: <CAEP_g=9JqFi7apps-aDqxuGck-hYSvaUT6pzXR-gDkAvLovS8A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-31 at 17:09 -0800, Jesse Gross wrote:
> 
> I would argue that the meanings are the same on transmit and receive
> but the values that you are likely to see differ depending on the
> path.  With bridging (which includes both Open vSwitch and the bridge)
> it's very difficult to know whether you are on the transmit or receive
> path.  Personally, I would just remove the warning completely.

I would keep it as it is, I fixed several RHEL kernel bugs exposed by
this warning, it is pretty useful for debugging.

...
> 
> You can just drop the change in the block above and gso_send_check()
> will take care of the rest.  Regardless of the state of the incoming
> packet, GSO needs the checksum to be reset to CHECKSUM_PARTIAL in
> order to work.

Right, makes sense.

> 
> I think this is a different problem, unrelated to the checksum issue.
> Can you test this patch:
> http://git.kernel.org/?p=linux/kernel/git/jesse/openvswitch.git;a=commit;h=d9d59089c43fc33eb403cbb928e56c131f191dd5
> 
> I believe it should fix the problem, although there are still a few
> lingering reports that I'm trying to track down.

I will try your patch together with my updated patch.

Thanks!
