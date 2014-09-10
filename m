From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH V2 net] core: Don't attempt to load the "" driver.
Date: Wed, 10 Sep 2014 08:50:50 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1748EC90@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D174862E0@AcuExch.aculab.com>
	<20140905.143241.114624370748725493.davem@davemloft.net>
	<063D6719AE5E284EB5DD2968C1650D6D1748BC57@AcuExch.aculab.com>
 <20140909.172410.519439746131615877.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:51058 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751931AbaIJIw1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 04:52:27 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 14960-03 for <netdev@vger.kernel.org>;
 Wed, 10 Sep 2014 09:52:16 +0100 (BST)
In-Reply-To: <20140909.172410.519439746131615877.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller
> From: David Laight <David.Laight@ACULAB.COM>
> Date: Mon, 8 Sep 2014 13:23:33 +0000
> 
> > This whole 'try to load the module' path should be predicated on
> > 'interface not found'.
> 
> And that's the first thing dev_load() does, it tries to look up the
> device by name, and only does the module load attempt if that fails.

OK, I'd not looked back at the code before making that comment.

> Nobody cares if the module load itself actually fails, dev_load()
> returns void after all.

The actual code path is typically:
	dev_load(net, ifr.ifr_name);
	rtnl_lock()
	ret = dev_xxx(net, &ifr, cmd);
	rtnl_unlock()

where the first thing dev_xxx() does is to call __dev_get_by_name()
(or the equivalent dev_get_by_name_rcu()) again.
So the code 'sort of' cares whether the module loaded.

I actually wonder when the module load is useful - must be useful sometimes,
otherwise it wouldn't have been added.

I thought ifr.ifr_name was likely to be (say) "eth2" - but the module
won't be called that.
Looks like some hack to get something like the 'bond' driver loaded,
but even then surely ifr.ifr_name would be "bond0" not "bond".

I've had a quick look with 'git blame', but dev_ioctl.c was split from
somewhere and doesn't contain the history.

	David.
