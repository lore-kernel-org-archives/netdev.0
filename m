From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/3] r8169: Use dev_kfree_skb in Tx cleanup path
Date: Fri, 1 May 2015 11:34:20 +0200
Message-ID: <20150501093420.GA11669@electric-eye.fr.zoreil.com>
References: <20150430205423.1512.13487.stgit@ahduyck-vm-fedora22>
 <20150430205824.1512.35158.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	Dept-HSGLinuxNICDev@qlogic.com, sony.chacko@qlogic.com,
	intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:49014 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995AbbEAJez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 05:34:55 -0400
Content-Disposition: inline
In-Reply-To: <20150430205824.1512.35158.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexander Duyck <alexander.h.duyck@redhat.com> :
> This change replaces the use of either dev_kfree_skb_any or
> dev_consume_skb_any in the Tx cleanup path of this driver with
> dev_kfree_skb.  There isn't any need for the "_any" version of these
> functions since the NAPI cleanup context is not a hard irq context.

netconsole ?

__dev_kfree_skb_any contains a big "if (... || irqs_disabled())" test
and the NAPI poll handler is called with irq disabled from
netpoll_send_skb_on_dev.

-- 
Ueimor
