From: Cong Wang <amwang@redhat.com>
Subject: Re: [net-next PATCH v6 0/3] net: reserve ports for applications using
 fixed port numbers
Date: Mon, 01 Mar 2010 12:15:28 +0800
Message-ID: <4B8B3F60.8030007@redhat.com>
References: <1267233952-5856-1-git-send-email-opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26984 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752992Ab0CAEMJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2010 23:12:09 -0500
In-Reply-To: <1267233952-5856-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila wrote:
> This patch introduces /proc/sys/net/ipv4/ip_local_reserved_ports which
> allows users to reserve ports for third-party applications.
> 
> The reserved ports will not be used by automatic port assignments
> (e.g. when calling connect() or bind() with port number 0). Explicit
> port allocation behavior is unchanged.
> 
> Changes from the previous version:
> - be more strict on accepted input (only comma separators, no spaces allowed)
> - add to the docs a paragraph about ip_local_port_range and
>   ip_local_reserved_ports relationship
> - fix a few corner cases with parsing
> 


Thanks for keeping working on this!

Then this version should be fine now.


> There are still some miss behaviors with regard to proc parsing in odd
> invalid cases (for "40000\0-40001" all is acknowledged but only 40000
> is accepted) but they are not easy to fix without changing the current
> "acknowledge how much we accepted" behavior.


I think this is the right behavior.

> 
> Because of that and because the same issues are present in the
> existing proc_dointvec code as well I don't think its worth holding
> the actual feature (port reservation) after such petty error recovery
> issues.
> 
> For the sake of discussion, I think Eric was right: the model we are
> using is messy, we should only accept all input or none. If we can
> (ABI implications) and you think its worth switching to this model I
> can give it a try in a future patch.
> 


Well, this depends, for things like "40000b", we should reject it,
since it is invalid, for "40000\0-40001", I think returning 5 is alright.

Thanks.
