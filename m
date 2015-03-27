From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [RFC net-next 1/2] net: allow user to set IPv6 nexthop for IPv4
 route
Date: Fri, 27 Mar 2015 10:10:57 -0400
Message-ID: <20150327141057.GG1051@gospo>
References: <1427403928-1342-1-git-send-email-gospo@cumulusnetworks.com>
 <1427403928-1342-2-git-send-email-gospo@cumulusnetworks.com>
 <5515449D.4080408@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Bjornar Ness <bjornar.ness@gmail.com>,
	Sowmini Varadhan <sowmini05@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:33660 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752214AbbC0OLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 10:11:09 -0400
Received: by ykek76 with SMTP id k76so40926361yke.0
        for <netdev@vger.kernel.org>; Fri, 27 Mar 2015 07:11:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5515449D.4080408@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 27, 2015 at 11:53:01AM +0000, Robert Shearman wrote:
> On 26/03/15 21:05, Andy Gospodarek wrote:
> >diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
> >index bea910f..26cdd01 100644
> >--- a/include/uapi/linux/rtnetlink.h
> >+++ b/include/uapi/linux/rtnetlink.h
> >@@ -306,6 +306,7 @@ enum rtattr_type_t {
> >         RTA_VIA,
> >         RTA_NEWDST,
> >         RTA_PREF,
> >+       RTA_GATEWAY6,
> 
> There shouldn't be any need to add a new attribute. The RTA_VIA attribute
> that Eric Biederman recently introduced should have the semantics that you
> require:
> 
> "RTA_VIA specifies the specifies the next machine to send a packet to
> like RTA_GATEWAY.  RTA_VIA differs from RTA_GATEWAY in that it
> includes the address family of the address of the next machine to send
> a packet to."

Absolutely.  I did this first set before Eric added the RTA_VIA
attribute, so I need to not only use it, but also add support in the
ipv4 code to use that attribute if set.
