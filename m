From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vmxnet3: ensure that adapter is in proper state during
 force_close
Date: Fri, 12 May 2017 12:24:14 -0400 (EDT)
Message-ID: <20170512.122414.1439442347417322148.davem@davemloft.net>
References: <20170512160001.24425-1-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, skhare@vmware.com, pv-drivers@vmware.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35432 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932922AbdELQYP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 12:24:15 -0400
In-Reply-To: <20170512160001.24425-1-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 12 May 2017 12:00:01 -0400

> There are several paths in vmxnet3, where settings changes cause the
> adapter to be brought down and back up (vmxnet3_set_ringparam among
> them).  Should part of the reset operation fail, these paths call
> vmxnet3_force_close, which enables all napi instances prior to calling
> dev_close (with the expectation that vmxnet3_close will then properly
> disable them again).  However, vmxnet3_force_close neglects to clear
> VMXNET3_STATE_BIT_QUIESCED prior to calling dev_close.  As a result
> vmxnet3_quiesce_dev (called from vmxnet3_close), returns early, and
> leaves all the napi instances in a enabled state while the device itself
> is closed.  If a device in this state is activated again, napi_enable
> will be called on already enabled napi_instances, leading to a BUG halt.
> 
> The fix is to simply enausre that the QUIESCED bit is cleared in
> vmxnet3_force_close to allow quesence to be completed properly on close.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Looks good, applied, thanks Neil.
