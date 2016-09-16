From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net: ipv6: Disable forwarding per interface via sysctl
Date: Fri, 16 Sep 2016 17:46:16 +0200
Message-ID: <188dbf56-c09c-259b-4e10-0e331c4be880@stressinduktion.org>
References: <1474030076-24809-1-git-send-email-mmanning@brocade.com>
 <1474033192.22679.67.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Mike Manning <mmanning@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:48074 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755855AbcIPPqS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 11:46:18 -0400
In-Reply-To: <1474033192.22679.67.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16.09.2016 15:39, Eric Dumazet wrote:
> On Fri, 2016-09-16 at 13:47 +0100, Mike Manning wrote:
>> Disabling forwarding per interface via sysctl continues to allow
>> forwarding. This is contrary to the sysctl documentation stating that
>> the forwarding sysctl is per interface, whereas currently it is only
>> the sysctl for all interfaces that has an effect on forwarding. The
>> solution is to drop any received packets instead of forwarding them
>> if the ingress device has a per-device forwarding sysctl that is unset.
> 
> Some archaeological research might be needed because
> Documentation/networking/ip-sysctl.txt states :
> 
> IPv4 and IPv6 work differently here; e.g. netfilter must be used
> to control which interfaces may forward packets and which not.
> 
> If this netfilter requirement is obsolete, then your patch would need to
> change the doc as well.
> 
> Hannes can probably comment on this ?

Yep, thanks.

This commit breaks a very common setup: people globally enabled
forwarding but disabled the forwarding knob on one special interface to
allow this interface to participate in auto configuration from their
provider while still forwarding packets over this interface.

I fear this is so common that this would be a uapi violation.

Thanks,
Hannes
