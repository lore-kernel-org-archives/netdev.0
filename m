From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: [PATCH 5/5] ixgbe: add driver set_max_vfs support
Date: Wed, 3 Oct 2012 13:37:18 -0700
Message-ID: <CAE9FiQXG1MGitFzv94CW+EUugntQR4C+8i4946K7ycHJA5WpGA@mail.gmail.com>
References: <506C3B11.9010009@redhat.com>
	<1349286695-26713-1-git-send-email-yinghai@kernel.org>
	<1349286695-26713-6-git-send-email-yinghai@kernel.org>
	<506C8837.5070902@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Bjorn Helgaas <bhelgaas@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org,
	Don Dutile <ddutile@redhat.com>, yuvalmin@broadcom.com,
	bhutchings@solarflare.com, gregory.v.rose@intel.com,
	davem@davemloft.net, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:42115 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753101Ab2JCUhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 16:37:20 -0400
In-Reply-To: <506C8837.5070902@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 3, 2012 at 11:47 AM, Alexander Duyck
<alexander.h.duyck@intel.com> wrote:
> The ixgbe_set_max_vfs function has several issues.  The two big ones are
> that this function assumes it can just enable/disable SR-IOV without any
> other changes being necessary which is not the case.  I would recommend
> looking at ixgbe_setup_tc for how to do this properly.  Secondly is the
> fact that this code will change the PF network device and as such
> sections of the code should be called with the RTNL lock held.  In
> addition I believe you have to disable SR-IOV before enabling it again
> with a different number of VFs.

yes, agreed.

>
> Below is a link to one of the early patches for igb when we were first
> introducing SR-IOV, and the in-driver sysfs value had been rejected.  I
> figure it might be useful as it was also using sysfs to enable/disable
> VFs.  It however doesn't have the correct locking on changing the queues
> and as such will likely throw an error if you were to implement it the
> same way now:
> http://lists.openwall.net/netdev/2009/04/08/34

yes, that is almost there if put that in-driver value to per device
value and ops.

Thanks

Yinghai
