From: David Ahern <dsahern@gmail.com>
Subject: Re: Unable to add v6 multipath route with same nexthops but different
 MPLS labels
Date: Wed, 5 Jul 2017 11:15:58 -0600
Message-ID: <73b4cf4b-4e65-3bc0-15c8-8a50ff6e4bdc@gmail.com>
References: <20170705153958.GL22185@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>,
        David Ahern <dsa@cumulusnetworks.com>,
        Robert Shearman <rshearma@brocade.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f50.google.com ([209.85.214.50]:35803 "EHLO
        mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751874AbdGERQA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 13:16:00 -0400
Received: by mail-it0-f50.google.com with SMTP id v202so117752358itb.0
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2017 10:16:00 -0700 (PDT)
In-Reply-To: <20170705153958.GL22185@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/5/17 9:39 AM, Lennert Buytenhek wrote:
> Hi!
> 
> FWIW, this doesn't work:
> 
> 	# ip -6 route add 1234::/16 \
> 		nexthop encap mpls 10 via fe80::1 dev ens3 \
> 		nexthop encap mpls 20 via fe80::1 dev ens3
> 	RTNETLINK answers: File exists
> 
> While this does:
> 
> 	# ip -6 route chg 1234::/16
> 		nexthop encap mpls 10 via fe80::1 dev ens3
> 		nexthop encap mpls 20 via fe80::2 dev ens3
> 	# ip -6 route
> 	1234::/16  encap mpls  10 via fe80::1 dev ens3 metric 1024 pref medium
> 	1234::/16  encap mpls  20 via fe80::2 dev ens3 metric 1024 pref medium
> 	[...]
> 
> ECMPing over different LSPs that share a nexthop router seems like a
> legitimate use case to me.  Is this restriction intentional or just an
> accident?  (The same thing works fine in v4 land, where multipath
> routes are handled differently.)
> 
> Thanks in advance!


Seems like a failure to compare lwt state. Will send a patch.
