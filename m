From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] division-by-zero in inet_csk_get_port
Date: Wed, 10 Oct 2007 03:01:53 -0700 (PDT)
Message-ID: <20071010.030153.09951294.davem@davemloft.net>
References: <m31wc3l4ym.fsf@bandura.englab.brq.redhat.com>
	<20071010.023515.15263796.davem@davemloft.net>
	<m3wstvjnso.fsf@bandura.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, den@openvz.org
To: aarapov@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39906
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750995AbXJJKBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 06:01:50 -0400
In-Reply-To: <m3wstvjnso.fsf@bandura.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Anton Arapov <aarapov@redhat.com>
Date: Wed, 10 Oct 2007 11:56:23 +0200

>   Yep, that's exactly I'm talking about. I'm sure that 
>   [...] % (high - low) [...] erroneous from the begining, because
> in such places we want to have 1 in denominator, for the cases when we
> have only one port. Because 34000 34000 in sysctl's
> ip_local_port_range means 1(one) port, not 0(zero).
> 
>   So it seems to me that we have to fix mentioned denominators in
> kernel/net to have 1, that will be correct logically. And do the
> MAX<MIN check in sysctl code.
>   From this point of view, it's best idea to have two patches: one for
> the kernel/net denominators and another one for the sysctl.c's
> function dointvec_minmax(). Because they can live independently. And
> the patch for the kernel/net will do the work at least because we
> prevent kernel trap at all.
>   
>   Dave, am I right?

Sure, two patches is fine.
