From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 2/2] Revert napi_poll fix for bonding driver
Date: Wed, 20 Oct 2010 15:52:00 +0800
Message-ID: <4CBE9FA0.6010900@redhat.com>
References: <1287507866-25156-1-git-send-email-nhorman@tuxdriver.com> <1287507866-25156-3-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	fubar@us.ibm.com, davem@davemloft.net, andy@greyhouse.net
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19989 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932106Ab0JTHrl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Oct 2010 03:47:41 -0400
In-Reply-To: <1287507866-25156-3-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/10 01:04, nhorman@tuxdriver.com wrote:
> From: Neil Horman<nhorman@tuxdriver.com>
>
> In an erlier patch I modified napi_poll so that devices with IFF_MASTER polled
> the per_cpu list instead of the device list for napi.  I did this because the
> bonding driver has no napi instances to poll, it instead expects to check the
> slave devices napi instances, which napi_poll was unaware of.  Looking at this
> more closely however, I now see this isn't strictly needed.  As the bond driver
> poll_controller calls the slaves poll_controller via netpoll_poll_dev, which
> recursively calls poll_napi on each slave, allowing those napi instances to get
> serviced.  The earlier patch isn't at all harmfull, its just not needed, so lets
> revert it to make the code cleaner.  Sorry for the noise,
>
> Signed-off-by: Neil Horman<nhorman@tuxdriver.com>

Looks reasonable to me,

Reviewed-by: WANG Cong <amwang@redhat.com>

Thanks.
