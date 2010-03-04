From: "Zhu, Yi" <yi.zhu@intel.com>
Subject: RE: [PATCH V2 5/7] sctp: use limited socket backlog
Date: Thu, 4 Mar 2010 10:00:17 +0800
Message-ID: <DA586906BA1FFC4384FCFD6429ECE860A45A6A8E@shzsmsx502.ccr.corp.intel.com>
References: <1267605389-7369-1-git-send-email-yi.zhu@intel.com>
 <1267605389-7369-2-git-send-email-yi.zhu@intel.com>
 <1267605389-7369-3-git-send-email-yi.zhu@intel.com>
 <1267605389-7369-4-git-send-email-yi.zhu@intel.com>
 <1267605389-7369-5-git-send-email-yi.zhu@intel.com>
 <4B8E6DD0.1020603@hp.com>
 <DA586906BA1FFC4384FCFD6429ECE860A45A699B@shzsmsx502.ccr.corp.intel.com>
 <4B8E73E5.1030105@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:36485 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752379Ab0CDCA4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 21:00:56 -0500
In-Reply-To: <4B8E73E5.1030105@hp.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad Yasevich <vladislav.yasevich@hp.com> wrote:

>> BTW, does the current backlog limit (sysctl_rmem_default[1] << 1) enough for sctp?
>> I noticed the sysctl_sctp_rmem[1] is set to 373500 in my box.
>> 

> sctp uses the same algorithm as TCP to figure out the memory values.
> I guess the issue with using the smaller value that it would be possible to
> queue more the socket receive buffer then to the backlog.  Thus backlog would
> start dropping packets even though receive buffer would still accept them.

Sysctl_tcp_rmem[1] = 87380 in my box which is much smaller than sctp. The backlog
limit is set to 258048 by default which is smaller than sysctl_sctp_rmem[1] = 373500.
I don't think backlog starts to drop packets before receive queue is correct. Fortunately
we can set the limit by individual protocols. I'll set the sk->sk_backlog.limit to
sysctl_sctp_rmem[1] in sctp_init_sock() for sctp socks in the next version.

Thanks,
-yi
