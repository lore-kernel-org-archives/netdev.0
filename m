From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH net] openvswitch: fix a possible deadlock and lockdep
 warning
Date: Thu, 27 Mar 2014 09:52:42 -0300
Message-ID: <20140327125242.GA2475@t520.home>
References: <1395881772-29781-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: openvswitch <dev@openvswitch.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11618 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752211AbaC0Mws (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2014 08:52:48 -0400
Content-Disposition: inline
In-Reply-To: <1395881772-29781-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please ignore this one.
I will repost with the correct openvswitch address.
Thanks

On Wed, Mar 26, 2014 at 09:56:12PM -0300, Flavio Leitner wrote:
> There are two problematic situations.
> 
> A deadlock can happen when is_percpu is false because it can get
> interrupted while holding the spinlock. Then it executes
> ovs_flow_stats_update() in softirq context which tries to get
> the same lock.
> 
> The second sitation is that when is_percpu is true, the code
> correctly disables BH only for the local CPU, but that confuses
> lockdep enough to trigger the warning below.
> 
> This patch disables BH for both cases fixing the real deadlock
> and the lockdep warning message.
[...]
 
