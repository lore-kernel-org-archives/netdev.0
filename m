From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [RFC PATCH net-next 0/9] netlink: strict attribute checking
 option
Date: Fri, 16 Oct 2015 09:39:45 +0200
Message-ID: <20151016093945.54a6a7aa@griffin>
References: <cover.1444926905.git.jbenc@redhat.com>
	<20151015.235007.973370825335101214.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41556 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752074AbbJPHjt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2015 03:39:49 -0400
In-Reply-To: <20151015.235007.973370825335101214.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Oct 2015 23:50:07 -0700 (PDT), David Miller wrote:
> Although we are probably stuck with this, it was probably a bad idea
> to have this behavior as the default.

I agree. But we have what we have.

> Better would have been to always error on unrecognized attributes, and
> in the ACK give some indication of which attribute was problematic.

Should I try to extend the patches to return such information back to
the user? It would mean more intrusiveness, as there's no space in ack
to store such information (it would have been better to use attributes
even in the error responses instead of a fixed structure...).

> But anyhow we are stuck with what we have.  However, I will say I am
> disappointed that it is so hard to simply detect that lwtunnel support
> is present, which as I understand is what this patch set is trying to
> accomplish.

Yes, main motivation is lwtunnel support. However, I'd say this is
useful outside of it, too.

> And this is quite an intrusive patch series, and therefore not
> suitable for -stable backports.  And that's exactly where you actually
> are going to need these changes right?  Older kernels that lack
> lwtunnel support.

I'm targeting net-next only and don't intend to bring this to older
kernels. The patchset is designed in the way that it's possible to
detect that the kernel does not support strict attribute checking. When
this is detected, the tools will just assume that lwtunnel support is
not there. That's completely okay, it will just mean that the 4.3
kernel will be treated as not having lwtunnel support; everything will
work correctly, including openvswitch (which will use its compat code).

 Jiri

-- 
Jiri Benc
