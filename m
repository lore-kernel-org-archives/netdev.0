From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 01/13] e1000e: Fix no connectivity when driver loaded
 with cable out
Date: Tue, 01 Apr 2014 16:06:18 +0400
Message-ID: <533AABBA.70603@cogentembedded.com>
References: <1396308899-20926-1-git-send-email-jeffrey.t.kirsher@intel.com> <1396308899-20926-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Ertman <davidx.m.ertman@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:58896 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752062AbaDAMGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 08:06:21 -0400
Received: by mail-la0-f41.google.com with SMTP id gl10so7024558lab.0
        for <netdev@vger.kernel.org>; Tue, 01 Apr 2014 05:06:19 -0700 (PDT)
In-Reply-To: <1396308899-20926-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01-04-2014 3:34, Jeff Kirsher wrote:

> From: David Ertman <davidx.m.ertman@intel.com>

> In commit da1e2046e5, the flow for enabling/disabling an Si errata

    Please also specify that commit's summary line in parens.

> workaround (e1000_lv_jumbo_workaround_ich8lan) was changed to fix a problem
> with iAMT connections dropping on interface down with jumbo frames set.
> Part of this change was to move the function call disabling the workaround
> to e1000e_down() from the e1000_setup_rctl() function.  The mechanic for
> disabling of this workaround involves writing several MAC and PHY registers
> back to hardware defaults.

> After this commit, when the driver is loaded with the cable out, the PHY
> registers are not programmed with the correct default values.  This causes
> the device to be capable of transmitting packets, but is unable to recieve
> them until this workaround is called.

> The flow of e1000e's open code relies upon calling the above workaround to
> expicitly program these registers either with jumbo frame appropriate settings
> or h/w defaults on 82579 and newer hardware.

> Fix this issue by adding logic to e1000_setup_rctl() that not only calls
> e1000_lv_jumbo_workaround_ich8lan() when jumbo frames are set, to enable the
> workaround, but also calls this function to explicitly disable the workaround
> in the case that jumbo frames are not set.

> Signed-off-by: Dave Ertman <davidx.m.ertman@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/e1000e/netdev.c | 20 +++++++++++++++-----
>   1 file changed, 15 insertions(+), 5 deletions(-)

[...]

WBR, Sergei
