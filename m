From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] phonet: Sort out initiailziation and cleanup code.
Date: Fri, 13 Apr 2012 11:05:21 -0400 (EDT)
Message-ID: <20120413.110521.1849736588108683587.davem@davemloft.net>
References: <m1mx6otk85.fsf@fess.ebiederm.org>
	<m1aa2otjf4.fsf_-_@fess.ebiederm.org>
	<m162dctjbo.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, ericvh@gmail.com, davej@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	levinsasha928@gmail.com, remi.denis-courmont@nokia.com
To: ebiederm@xmission.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m162dctjbo.fsf_-_@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 06 Apr 2012 18:35:39 -0700

> 
> Recently an oops was reported in phonet if there was a failure during
> network namespace creation.
 ...
> After investigation it turns out there were two issues.
> 1) Phonet was not implementing network devices but was using register_pernet_device
>    instead of register_pernet_subsys.
> 
>    This was allowing there to be cases when phonenet was not initialized and
>    the phonet net_generic was not set for a network namespace when network
>    device events were being reported on the netdevice_notifier for a network
>    namespace leading to the oops above.
> 
> 2) phonet_exit_net was implementing a confusing and special case of handling all
>    network devices from going away that it was hard to see was correct, and would
>    only occur when the phonet module was removed.
> 
>    Now that unregister_netdevice_notifier has been modified to synthesize unregistration
>    events for the network devices that are extant when called this confusing special
>    case in phonet_exit_net is no longer needed.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Also applied, thanks Eric.
