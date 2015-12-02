From: Flavio Leitner <fbl@sysclose.org>
Subject: Re: [PATCH net] openvswitch: fix hangup on vxlan/gre/geneve device
 deletion
Date: Wed, 2 Dec 2015 13:58:17 -0200
Message-ID: <20151202155817.GA8829@x240.home>
References: <d3c53f79dfaacd71bebf97427388d60dc5652eae.1448989843.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>, dev@openvswitch.org
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender163-mail.zoho.com ([74.201.84.163]:25749 "EHLO
	sender163-mail.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755985AbbLBP6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 10:58:30 -0500
Content-Disposition: inline
In-Reply-To: <d3c53f79dfaacd71bebf97427388d60dc5652eae.1448989843.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 01, 2015 at 06:33:36PM +0100, Paolo Abeni wrote:
> Each openvswitch tunnel vport (vxlan,gre,geneve) holds a reference
> to the underlying tunnel device, but never released it when such
> device is deleted.
> Deleting the underlying device via the ip tool cause the kernel to
> hangup in the netdev_wait_allrefs() loop.
> This commit ensure that on device unregistration dp_detach_port_notify()
> is called for all vports that hold the device reference, properly
> releasing it.
> 
> Fixes: 614732eaa12d ("openvswitch: Use regular VXLAN net_device device")
> Fixes: b2acd1dc3949 ("openvswitch: Use regular GRE net_device instead of vport")
> Fixes: 6b001e682e90 ("openvswitch: Use Geneve device.")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---

LGTM and fixes the issue in my env.

Acked-by: Flavio Leitner <fbl@sysclose.org>
