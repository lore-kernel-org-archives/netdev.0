From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [net] net_sched: make dev_trans_start return vlan's real dev
 trans_start
Date: Sat, 3 Aug 2013 19:07:33 +0200
Message-ID: <20130803170733.GA10218@redhat.com>
References: <1375542471-22739-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, davem@davemloft.net, fubar@us.ibm.com,
	jhs@mojatatu.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28983 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752523Ab3HCRHD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Aug 2013 13:07:03 -0400
Content-Disposition: inline
In-Reply-To: <1375542471-22739-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 03, 2013 at 05:07:51PM +0200, nikolay@redhat.com wrote:
...snip...
>+	while (is_vlan_dev(dev))
>+		dev = vlan_dev_real_dev(dev);

While at it - I've checked a few users (mainly network drivers) of
vlan_dev_real_dev(dev) and they all rely on that the return device would be
the *real* device, but not another vlan.

So maybe we should move this while loop to vlan_dev_real_dev() instead?
