From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [ovs-dev] [PATCH net 1/2] vxlan: Relax the MTU constraint on
 vxlan devices
Date: Sun, 10 Jan 2016 11:28:36 +0100
Message-ID: <20160110102836.GD1190@pox.localdomain>
References: <1452087186-12926-1-git-send-email-david@weave.works>
 <1452087186-12926-2-git-send-email-david@weave.works>
 <569153F8.4070500@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Wragg <david@weave.works>, dev@openvswitch.org,
	netdev@vger.kernel.org
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:32927 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755715AbcAJK2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 05:28:39 -0500
Received: by mail-wm0-f41.google.com with SMTP id f206so181615530wmf.0
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 02:28:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <569153F8.4070500@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/09/16 at 10:39am, roopa wrote:
> On 1/6/16, 5:33 AM, David Wragg wrote:
> > Allow the MTU of vxlan devices without an underlying device to be set to
> > larger values (up to a maximum based on IP packet limits and vxlan
> > overhead).
> >
> > Previously, their MTUs could not be set to higher than the conventional
> > ethernet value of 1500.  This is a very arbitrary value in the context
> > of vxlan, and prevented such vxlan devices from being able to take
> > advantage of jumbo frames etc.
> >
> > The default MTU remains 1500, for compatibility.
> >
> > Signed-off-by: David Wragg <david@weave.works>
> >
> Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> I have an internal patch which does the same thing and
> was hoping to post it soon.
> I am not using ovs. so, I am not closely following the thread on the other
> patch in the series. But, this patch certainly stands on its own and is required.

Agreed. In fact the issue described is not OVS specific, anyone using a
tunnel device in metadata mode benefits form this but is also exposed
to the MTU issue.

We either create a tunnel device for each underlay device and thus
expose the baremetal MTU into the virtual network thus allowing for
the L3 in the virtual network to check the MTU or we will not notice
until we hit the underlay in which the context for the ICMP is much
less useful.

I'll think about how to solve this as discussed in the other portion
of this thread as I assume you will be interested in a fix for this as
well.
