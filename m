From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2 1/2] gtp: rename SGSN netlink attribute
Date: Tue, 21 Mar 2017 16:15:11 +0100
Message-ID: <20170321151511.GA20650@salvia>
References: <20170203091231.10142-1-jonas@southpole.se>
 <20170321150430.23314-1-jonas@southpole.se>
 <20170321150748.GA20384@salvia>
 <7eb92d97-7f36-525b-f3dc-57295adc637b@southpole.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: laforge@gnumonks.org, netdev@vger.kernel.org
To: Jonas Bonn <jonas@southpole.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55496 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757180AbdCUPXn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Mar 2017 11:23:43 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id E71D1174D1B
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 16:15:16 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id D3944DA86C
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 16:15:16 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id AC32CDA86C
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 16:15:14 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <7eb92d97-7f36-525b-f3dc-57295adc637b@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 21, 2017 at 04:10:26PM +0100, Jonas Bonn wrote:
> On 03/21/2017 04:07 PM, Pablo Neira Ayuso wrote:
> >On Tue, Mar 21, 2017 at 04:04:29PM +0100, Jonas Bonn wrote:
> >>diff --git a/include/uapi/linux/gtp.h b/include/uapi/linux/gtp.h
> >>index 72a04a0..c51ebb0 100644
> >>--- a/include/uapi/linux/gtp.h
> >>+++ b/include/uapi/linux/gtp.h
> >>@@ -19,7 +19,7 @@ enum gtp_attrs {
> >>  	GTPA_LINK,
> >>  	GTPA_VERSION,
> >>  	GTPA_TID,	/* for GTPv0 only */
> >>-	GTPA_SGSN_ADDRESS,
> >>+	GTPA_PEER_ADDRESS,	/* Remote GSN peer, either SGSN or GGSN */
> >We need here:
> >
> >#define GTPA_SGSN_ADDRESS GTPA_PEER_ADDRESS
> >
> >for backward compatibility. Anything that is exposed through uapi
> >cannot be changed.
> 
> Yes... look a couple of lines further down...
> 
> >>  	GTPA_MS_ADDRESS,
> >>  	GTPA_FLOW,
> >>  	GTPA_NET_NS_FD,
> >>@@ -29,5 +29,6 @@ enum gtp_attrs {
> >>  	__GTPA_MAX,
> >>  };
> >>  #define GTPA_MAX (__GTPA_MAX + 1)
> >>+#define GTPA_SGSN_ADDRESS GTPA_PEER_ADDRESS /* maintain legacy attr name */
> 
> ^^^^... there it is! :)

Oh right!

Please, move it there to the enum definition, just after the new
GTPA_PEER_ADDRESS. We usually do this in other areas of the networking
code.

You also have to resubmit indicating net-next in your patch subject,
ie.  [PATCH net-next v3 1/2] gtp: rename SGSN netlink attribute

David usually requests that you explicitly indicate the target tree in
some way.

Thanks!
