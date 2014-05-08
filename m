From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] sctp: add a checking for
 sctp_sysctl_net_register
Date: Thu, 8 May 2014 07:41:24 -0400
Message-ID: <20140508114124.GD9696@hmsreliant.think-freely.org>
References: <536B3859.2050908@huawei.com>
 <20140508111126.GC9696@hmsreliant.think-freely.org>
 <536B69E3.1090104@huawei.com>
 <536B6AFD.40303@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55141 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753294AbaEHLlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 07:41:36 -0400
Content-Disposition: inline
In-Reply-To: <536B6AFD.40303@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 08, 2014 at 07:31:09PM +0800, Wang Weidong wrote:
> On 2014/5/8 19:26, Wang Weidong wrote:
> > On 2014/5/8 19:11, Neil Horman wrote:
> >> On Thu, May 08, 2014 at 03:55:05PM +0800, Wang Weidong wrote:
> >>> When register_net_sysctl failed, we should free the
> >>> sysctl_table while the net_namespace is not init_net.
> >>>
> >>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> >>> ---
> >>>  net/sctp/sysctl.c | 5 +++++
> >>>  1 file changed, 5 insertions(+)
> >>>
> >>> diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
> >>> index 844d2b0..4c17694 100644
> >>> --- a/net/sctp/sysctl.c
> >>> +++ b/net/sctp/sysctl.c
> >>> @@ -450,6 +450,11 @@ int sctp_sysctl_net_register(struct net *net)
> >>>  	}
> >>>  
> >>>  	net->sctp.sysctl_header = register_net_sysctl(net, "net/sctp", table);
> >>> +	if (net->sctp.sysctl_header == NULL) {
> >>> +		if (!net_eq(net, &init_net))
> >>> +			kfree(table);
> >>> +		return -ENOMEM;
> >>> +	}
> >> Sorry, we're not special casing this in 3 places.  Why not just revert the
> >> origonal commit so that all the sysctl tables can be handled the same way
> >> Neil
> >>
> > Hi Neil,
> > 
> > The original commit avoids to kmemdup 
> > 
> Hi Neil,
> 
> Sorry for the accomplished mail.
> Although, revert the original commit, the checking for net->sctp.sysctl_header
> is need from coding view.
> 
> What do you think?
> 
That was my review.  I get that the origional commit avoids kmemdup for the
init_net case.  My point was that, in so doing you created the need to special
case the handling of the sysctl table for init_net in 3 places now.  It seems to
me that, while its always nice to save space, it would be cleaner programming to
just accept the need for the extra 1.6Kb of space and not have to worry about
the special casing.

Neil

> Regards
> Wang
> 
> >>>  	return 0;
> >>>  }
> >>>  
> >>> -- 
> >>> 1.7.12
> >>>
> >>>
> >>>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe netdev" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>
> >>
> > 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
