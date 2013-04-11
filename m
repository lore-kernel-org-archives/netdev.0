From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] vxlan: revert "vxlan: Bypass encapsulation if
 the destination is local"
Date: Thu, 11 Apr 2013 10:10:15 +0800
Message-ID: <1365646215.25993.3.camel@cr0>
References: <1365501445-9712-1-git-send-email-amwang@redhat.com>
	 <1365530913.29336.50.camel@oc1677441337.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44423 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762074Ab3DKCP6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Apr 2013 22:15:58 -0400
In-Reply-To: <1365530913.29336.50.camel@oc1677441337.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-09 at 11:08 -0700, Sridhar Samudrala wrote:
> On Tue, 2013-04-09 at 17:57 +0800, Cong Wang wrote:
> > From: Cong Wang <amwang@redhat.com>
> > 
> > This reverts commit 9dcc71e1fdbb7aa10d92a3d35e8a201adc84abd0.
> > It apparently breaks my vxlan tests between different namespaces.
> > 
> I haven't tried vxlan with network namespaces.
> This patch effects the following 2 code paths
> - when source and destination endpoints are on the same bridge and
>   route short-circuiting is enabled. I guess you are not hitting
>   this path as this is possible only if you specify 'rsc' flag when
>   creating vxlan device.

No, I didn't specify this flag.

> - when source and destination endpoints belonging to different vni's
>   are on 2 different bridges on the same host. encap bypass is done
>   in this scenario by checking if rt_flags has RTCF_LOCAL set. I think
>   you must be hitting this path and the following patch should fix
>   it by only doing bypass if the source and dest devices belong to 
>   the same net. Can you try it and see if it fixes your tests?

I just tested it, unfortunately it doesn't work, the bug still exists.

If you need any other info, please let me know.

Thanks.
