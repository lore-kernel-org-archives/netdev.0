From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 1/1][PKT_CLS] Avoid multiple tree locks
Date: Thu, 22 Mar 2007 02:07:19 -0400
Message-ID: <1174543640.4895.28.camel@localhost>
References: <1174471116.16343.10.camel@localhost>
	 <4601047A.6050108@trash.net> <46010641.3000009@trash.net>
	 <4601268D.7090003@trash.net>  <46013B73.2060804@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.225]:46396 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965824AbXCVGHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 02:07:25 -0400
Received: by nz-out-0506.google.com with SMTP id s1so455533nze
        for <netdev@vger.kernel.org>; Wed, 21 Mar 2007 23:07:25 -0700 (PDT)
In-Reply-To: <46013B73.2060804@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-21-03 at 15:04 +0100, Patrick McHardy wrote:
> Patrick McHardy wrote:
 
> > What we could do is replace the netlink cb_lock spinlock by a
> > user-supplied mutex (supplied to netlink_kernel_create, rtnl_mutex
> > in this case). That would put the entire dump under the rtnl and
> > allow us to get rid of qdisc_tree_lock and avoid the need to take
> > dev_base_lock during qdisc dumping. Same in other spots like
> > rtnl_dump_ifinfo, inet_dump_ifaddr, ...
> 
> 
> These (compile tested) patches demonstrate the idea. 
>
> The first one
> lets netlink_kernel_create users specify a mutex that should be
> held during dump callbacks, the second one uses this for rtnetlink
> and changes inet_dump_ifaddr for demonstration.
> 
> A complete patch would allow us to simplify locking in lots of
> spots, all rtnetlink users currently need to implement extra
> locking just for the dump functions, and a number of them
> already get it wrong and seem to rely on the rtnl.
> 

The mutex is certainly a cleaner approach;
and a lot of the RCU protection would go away. I like it.

Knowing you i sense theres something clever in there that i am 
missing. I dont see how you could get rid of the tree locking
since we need to protect against the data path still, no?
Or are you looking at that as a separate effort?

> If there are no objections to this change I'm going to update
> the second patch to include all rtnetlink users.

No objections here.

cheers,
jamal

