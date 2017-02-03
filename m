From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v5 2/4] ifstat: Add extended statistics to
 ifstat
Date: Fri, 3 Feb 2017 10:07:25 -0800
Message-ID: <20170203100725.3d0b9791@xeon-e3>
References: <1485434681-33947-1-git-send-email-nogahf@mellanox.com>
 <1485434681-33947-3-git-send-email-nogahf@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        roszenrami@gmail.com, jbenc@redhat.com,
        sergei.shtylyov@cogentembedded.com, jiri@mellanox.com,
        eladr@mellanox.com, idosch@mellanox.com, yotamg@mellanox.com,
        ogerlitz@mellanox.com
To: Nogah Frankel <nogahf@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35566 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751761AbdBCSH3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 13:07:29 -0500
Received: by mail-pf0-f172.google.com with SMTP id f144so7494297pfa.2
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 10:07:29 -0800 (PST)
In-Reply-To: <1485434681-33947-3-git-send-email-nogahf@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Jan 2017 14:44:39 +0200
Nogah Frankel <nogahf@mellanox.com> wrote:

> Extended stats are part of the RTM_GETSTATS method. This patch adds them
> to ifstat.
> While extended stats can come in many forms, we support only the
> rtnl_link_stats64 struct for them (which is the 64 bits version of struct
> rtnl_link_stats).
> We support stats in the main nesting level, or one lower.
> The extension can be called by its name or any shorten of it. If there is
> more than one matched, the first one will be picked.
> 
> To get the extended stats the flag -x <stats type> is used.
> 
> Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
> Reviewed-by: Jiri Pirko <jiri@mellanox.com>

Sorry I was confused because RTM_GETSTATS contains multiple statistics.
Your patch is about getting LINK_XSTATS and after looking in more detail, you are
correct this should be an option. Although it would make sense to show this as addition
to the basic statistics. And when I tested it no output happens which seems confusing.

$ ./misc/ifstat -p -x cpu_hits
#kernel
Interface        RX Pkts/Rate    TX Pkts/Rate    RX Data/Rate    TX Data/Rate  
                 RX Errs/Drop    TX Errs/Drop    RX Over/Rate    TX Coll/Rate 

What I was intending in earlier discussion was using IFLA_STATS_LINK_64 which would
allow supporting 64 bit statistics on 32 bit platforms.
 
