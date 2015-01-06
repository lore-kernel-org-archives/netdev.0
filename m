From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [net 1/3] i40e: fix un-necessary Tx hangs
Date: Tue, 6 Jan 2015 09:04:40 -0800
Message-ID: <20150106090440.00006a7d@unknown>
References: <1420533864-13125-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1420533864-13125-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <nhorman@redhat.com>,
	<sassmann@redhat.com>, <jogreene@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:13052 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755388AbbAFREz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2015 12:04:55 -0500
In-Reply-To: <1420533864-13125-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 6 Jan 2015 00:44:22 -0800
Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> When the driver was polling with interrupts disabled the hardware
> will occasionally not write back descriptors.  This patch causes
> the driver to detect this situation and force an interrupt to
> fire which will flush the stuck descriptor.  Does not conflict
> with NAPI because if we are already polling the napi_schedule is
> ignored.  Additionally the extra interrupts are rate limited, so
> don't cause a burden to the CPU.

Dave, sorry to do this but we discovered a bug in this patch (where
this patch impacts performance) and didn't interrupt Jeff before he sent
it (my mistake) I will prep a v2 for Jeff.

Please do not apply.
