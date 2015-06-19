From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC v2 2/3] ipv4: add support for light weight
 tunnel encap attributes
Date: Fri, 19 Jun 2015 11:42:00 -0700
Message-ID: <55846278.6000807@cumulusnetworks.com>
References: <1434689355-4088-3-git-send-email-roopa@cumulusnetworks.com> <558432F1.5040209@brocade.com> <55843522.7060804@cumulusnetworks.com> <55844EB9.6040107@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, tgraf@suug.ch, davem@davemloft.net,
	netdev@vger.kernel.org
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34163 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755340AbbFSSmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 14:42:03 -0400
Received: by pabvl15 with SMTP id vl15so44262346pab.1
        for <netdev@vger.kernel.org>; Fri, 19 Jun 2015 11:42:02 -0700 (PDT)
In-Reply-To: <55844EB9.6040107@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/19/15, 10:17 AM, Robert Shearman wrote:
>
> No need for that - use the example of how RTA_MULTIPATH is used for 
> ipv4/ipv6:
>
> +----------------------+
> | RTA_MULTIPATH        |
> +----------------------+
> | +------------------+ |
> | | struct rtnexthop | |
> | +------------------+ |
> | | RTA_GATEWAY, etc.| |
> | +------------------+ |
> +----------------------+
>
> You could do similar for RTA_ENCAP where the type is stored in the 
> data prior to the nested attributes starting. E.g.:
>
> +----------------------+
> | RTA_ENCAP            |
> +----------------------+
> | +------------------+ |
> | | struct rtencap   | |
> | +------------------+ |
> | | MPLS_IPTUNNEL_DST| |
> | +------------------+ |
> +----------------------+
>
> struct rtencap {
>     __u16 rte_type;
> };
I did think about that...but today the rtnextop seems like it was 
written a struct initially and then extended with attributes only 
because the struct could not be extended (I maybe wrong). But half the 
fields are in a struct and the others are attributes. It gets confusing.
And i was trying to avoid that.
