From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH iproute2 1/3] vxlan: add support for collect metadata
 flag
Date: Wed, 16 Dec 2015 11:50:53 +0100
Message-ID: <20151216115054.47dca715@griffin>
References: <cover.1450193891.git.pabeni@redhat.com>
	<c83d317f4849cbbb1b0551d450c3972c5bc73e2b.1450193891.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemming@brocade.com, netdev@vger.kernel.org,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52534 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751232AbbLPKu5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 05:50:57 -0500
In-Reply-To: <c83d317f4849cbbb1b0551d450c3972c5bc73e2b.1450193891.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Dec 2015 16:48:25 +0100, Paolo Abeni wrote:
> This patch add support for IFLA_VXLAN_COLLECT_METADATA via the
> 'collectmetadata' keyword to the vxlan link.

Could we give this more understandable name? I've never liked the
COLLECT_METADATA name as it describes the actual implementation, not
the intention of the flag.

The name should express that the vxlan interface is driven by an
external control plane instead of the internal fdb. This could be ovs,
a route, tc action, etc. Something like "external" would be better
name, I think.

Also, as a related remark, please note that IFLA_VXLAN_COLLECT_METADATA
is mutually exclusive with many other flags. It's currently not
enforced correctly at the kernel level (instead, you get weird
behavior). I'll fix this on the kernel side but we may want to enforce
this on the iproute2 side, too, to get a better error message. This is
not to be addressed by this patch, though.

 Jiri

-- 
Jiri Benc
