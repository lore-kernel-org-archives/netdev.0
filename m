From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 0/7] secid reconciliation-v02: Repost patchset with updates
Date: Fri, 08 Sep 2006 11:50:24 -0500
Message-ID: <45019F50.1090408@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, sds@tycho.nsa.gov, chanson@trustedcs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:37999 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1750914AbWIHQus
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Sep 2006 12:50:48 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following are the changes included in this patchset since the previous post:

- Perform flow_in check before (as opposed to after) computing transition
  secid on inbound; this seems more intuitive and correct.
- Implement reconciliation and flow control for outbound traffic
  (forward case being a sequence of inbound checks followed by outbound checks).
- Make selinux_xfrm_postroute_last checks conditional on compat_net.

This patchset is relative to David Miller's net-2.6.19.git (last updated on Sep 1st).

Please consider for inclusion in 2.6.19.


UPCOMING WORK:

The following per the discussion at:
  http://marc.theaimsgroup.com/?l=selinux&m=115755980516072&w=2

- Create IPSec SAs to be acquired with the creating sock's context as opposed
  to that of the matching SPD rule, resulting in a simpler SPD as well as policy.
- Set peer_sid on tcp sockets to the reconciled secmark so trusted applications
  can retrieve and service the data at the appropriate context.
