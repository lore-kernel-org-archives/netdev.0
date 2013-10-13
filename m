From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v2 net-next] openvswitch: fix vport-netdev unregister
Date: Sun, 13 Oct 2013 21:22:11 +0000 (UTC)
Message-ID: <slrnl5m3oc.3lg.xiyou.wangcong@linux-6brj.site>
References: <1381540347-3679-1-git-send-email-ast@plumgrid.com>
Cc: dev@openvswitch.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:54891 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755256Ab3JMVWe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Oct 2013 17:22:34 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1VVT7R-0001IC-S9
	for netdev@vger.kernel.org; Sun, 13 Oct 2013 23:22:33 +0200
Received: from c-67-169-68-218.hsd1.ca.comcast.net ([67.169.68.218])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 13 Oct 2013 23:22:33 +0200
Received: from xiyou.wangcong by c-67-169-68-218.hsd1.ca.comcast.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 13 Oct 2013 23:22:33 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 12 Oct 2013 at 01:12 GMT, Alexei Starovoitov <ast@plumgrid.com> wrote:
> @@ -87,7 +81,11 @@ static int dp_device_event(struct notifier_block *unused, unsigned long event,
>  	if (!vport)
>  		return NOTIFY_DONE;
>  
> -	if (event == NETDEV_UNREGISTER) {
> +	if (event == NETDEV_UNREGISTER && dev->priv_flags & IFF_OVS_DATAPATH) {
> +		/* upper_dev_unlink and decrement promisc immediately */
> +		ovs_netdev_detach_dev(vport);
> +
> +		/* schedule vport destroy, dev_put and genl notification */

ovs_netdev_get_vport() already checks IFF_OVS_DATAPATH flag before this 'if'.
