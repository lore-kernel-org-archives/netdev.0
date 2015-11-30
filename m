From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] openvswitch: properly refcount vport-vxlan module
Date: Sun, 29 Nov 2015 22:56:02 -0500 (EST)
Message-ID: <20151129.225602.1084348710294716685.davem@davemloft.net>
References: <1448471127-26271-1-git-send-email-pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com, tgraf@suug.ch
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48300 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751840AbbK3D4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 22:56:04 -0500
In-Reply-To: <1448471127-26271-1-git-send-email-pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Wed, 25 Nov 2015 18:05:27 +0100

> After 614732eaa12d, no refcount is mainteined for the vport-vxlan module.
> This allows the userspace to remove such module while vport-vxlan
> devices still exist, which lead to later oops, i.e. when
> the openvswitch module is removed.
> 
> Fixes: 614732eaa12d ("openvswitch: Use regular VXLAN net_device device")
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

This is so error prone, with some vport_ops needing to mark the
module and some don't (because they are in the main openvswitch
driver).

Fix this properly, by making the vport_ops register function be
a macro that sets THIS_MODULE in the vport_ops before passing it
on down to the real registry function.
