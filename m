From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: vxlan: do not use vxlan_net before checking
 event type
Date: Mon, 20 Jan 2014 23:01:47 +0100
Message-ID: <52DD9CCB.3050101@redhat.com>
References: <1389959706-30976-1-git-send-email-dborkman@redhat.com> <87eh428gpx.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64225 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752971AbaATWBy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jan 2014 17:01:54 -0500
In-Reply-To: <87eh428gpx.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/20/2014 10:51 PM, Eric W. Biederman wrote:
...
> I am not going to argue against this patch as an immediate bug fix but
> something smells here, that bears deeper investigation.  It looks like
> the symptom is being patched rather than the actual problem.
>
> In particular net_generic(dev_net(dev), vxlan_net_id) is valid at the
> point that it is being called.  As the pointers are allocated in
> copy_net_ns in net_alloc prior to setup_net being called.
>
> On the flip side it is the responsibility of code that uses both
> register_netdev_notifier and register_pernet_xxx to be ready to handle
> events from any namespace as soon as they happen.  vxlan should be using
> register_pernet_subsys instead of register_pernet_device to ensure the
> vxlan_net structure is initialized before and cleaned up after all
> network devices in a given network namespace.  The vlan devices with a
> similar problem already do this.
>
> So in summary.  Something smells and I don't believe this patch fixes
> the underlying issue.  Please take a deeper look into what vxlan is doing.

Thanks for the input Eric!

If no-one is faster than me, I'll try to look into it soon.
