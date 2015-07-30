From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v5 0/2] af_mpls: fix undefined reference to ip6_route_output
 with CONFIG_IPV6=n
Date: Thu, 30 Jul 2015 06:22:55 -0700
Message-ID: <55BA252F.3070601@cumulusnetworks.com>
References: <1438122461-8350-1-git-send-email-roopa@cumulusnetworks.com> <20150729.224223.1592092790674598920.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, hannes@stressinduktion.org, rshearma@brocade.com,
	stephen@networkplumber.org, kuznet@ms2.inr.ac.ru,
	jon.maloy@ericsson.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:33804 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbbG3NW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 09:22:57 -0400
Received: by pdbbh15 with SMTP id bh15so24459325pdb.1
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 06:22:57 -0700 (PDT)
In-Reply-To: <20150729.224223.1592092790674598920.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/29/15, 10:42 PM, David Miller wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> Date: Tue, 28 Jul 2015 15:27:39 -0700
>
>> v4 - v5: Use ipv6_stub_impl.ipv6_dst_lookup as suggested by Hannes
> I think this might not work.
>
> The ipv6_stub pointer is NULL until the ipv6 module is loaded.
>
> VXLAN can safely call through ipv6_stub->foo() because it _knows_ the
> ipv6 module has been loaded, and will not go away, because it is
> working with an ipv6 socket.
>
> You don't have that set of preconditions here, and thus it is pretty
> easy to generate a scenerio where ipv6_stub will be NULL at your call
> sites.

v4 seems to be a better/safe option in that case. I can resubmit v4 if 
that is acceptable.

>
> This is starting to get really messy, to be honest.  And we've been
> harboring this build failure for several days now.
>
please revert the commit that introduced the IPV6 dependency. I will 
resubmit if needed.
I don't feel good about the build failure either.

Thanks and apologies.

commit 01faef2cebae02685e2bcfc9bbee8416d5ec19fc
Author: Roopa Prabhu <roopa@cumulusnetworks.com>
Date:   Tue Jul 21 09:16:24 2015 -0700

     mpls: make RTA_OIF optional

     If user did not specify an oif, try and get it from the via address.
     If failed to get device, return with -ENODEV.
