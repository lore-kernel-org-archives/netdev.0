From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net] sfc: skip ptp allocations on secondary interfaces
Date: Fri, 16 Dec 2016 10:48:15 -0500
Message-ID: <adb8c79f-313d-f93f-1f8b-970bda5e6df1@redhat.com>
References: <20161215203104.12714-1-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com,
        Edward Cree <ecree@solarflare.com>,
        Bert Kenward <bkenward@solarflare.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49066 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1761760AbcLPPsP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Dec 2016 10:48:15 -0500
In-Reply-To: <20161215203104.12714-1-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-12-15 3:31 PM, Jarod Wilson wrote:
> Rather than allocating efx_ptp_data, a buffer, a workqueue, etc., and then
> ultimately deciding not to call ptp_clock_register() for non-primary
> interfaces, just exit out of efx_ptp_prober() earlier. Saves a little
> memory and speeds up init and teardown slightly.
>
> CC: linux-net-drivers@solarflare.com
> CC: Edward Cree <ecree@solarflare.com>
> CC: Bert Kenward <bkenward@solarflare.com>
> CC: netdev@vger.kernel.org
> Signed-off-by: Jarod Wilson <jarod@redhat.com>

Self-Nak on this one. Talking to Bert off-list, he pointed out that the 
driver uses the PTP structure allocated here for the secondary interface 
to do internal time-stamping and the like. While it might be ideal not 
to intermingle PTP structs with non-PTP work, disabling this right now 
is obviously a non-starter.

-- 
Jarod Wilson
jarod@redhat.com
