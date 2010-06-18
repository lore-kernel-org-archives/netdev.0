From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch 2/2] mlx4: add dynamic LRO disable support
Date: Fri, 18 Jun 2010 11:10:31 +0800
Message-ID: <4C1AE3A7.6010004@redhat.com>
References: <20100603034303.5305.55552.sendpatchset@localhost.localdomain> <20100603034312.5305.61000.sendpatchset@localhost.localdomain> <1275568622.2870.89.camel@localhost> <4C085D45.6040001@redhat.com> <1275661552.2095.13.camel@achroite.uk.solarflarecom.com> <4C0F5D97.5030605@redhat.com> <20100609104950.GB2599@dhcp-lab-161.englab.brq.redhat.com> <4C173F87.7000704@redhat.com> <20100615113926.30d0cd01@dhcp-lab-109.englab.brq.redhat.com> <4C19FEE4.4000804@redhat.com> <20100617120318.GA4059@dhcp-lab-161.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	herbert.xu@redhat.com, nhorman@redhat.com, davem@davemloft.net
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29687 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755611Ab0FRD3Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jun 2010 23:29:24 -0400
In-Reply-To: <20100617120318.GA4059@dhcp-lab-161.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/10 20:03, Stanislaw Gruszka wrote:
> On Thu, Jun 17, 2010 at 06:54:28PM +0800, Cong Wang wrote:
>>>> I don't think mdev->state_lock is used to protect dev->feature.
>>>> rtnl_lock is. I think switching to mlx4_ethtool_op_set_flags()
>>>> from the default one has already solved this.
>>>
>>> Ahh, you have right, may intention was use it to stop and start
>>> port. Code rather should look like below:
>>>
>>> 	if (netdev_running(dev)) {
>>> 		mutex_lock(&mdev->state_lock);
>>> 		mlx4_en_stop_port(dev);
>>> 	}
>>>
>>> 	dev->features ^= NETIF_F_LRO;
>>>
>>> 	if (netdev_running(dev)) {
>>> 		rc = mlx4_en_start_port(dev);
>>> 		mutex_unlock(&mdev->state_lock);
>>>    		if (rc)
>>> 		en_err(priv, "Failed to restart port\n");
>>> 	}
>>>
>>
>> Hmm, you mean ->features should be changed after port is stopped?
>
> Actually not ->features variable, but NETIF_F_LRO bit, as only this
> bit is used in rx path.
>

Yeah, this is what I meant.

>> Why?
>
> For reasons you talked before in this thread :) to do not change
> LRO in the middle of receiving packages.
>

Ohh... I missed this, seems reasonable, will fix this in the next update.

Thanks.
