From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vxlan: add necessary locking on device removal
Date: Tue, 16 Jul 2013 23:06:00 -0700 (PDT)
Message-ID: <20130716.230600.734017943782172716.davem@davemloft.net>
References: <CALnjE+oDwU46NiK-AyB-dJZVrWT-pot_v+obv+MxgZU0xNwbRw@mail.gmail.com>
	<20130716.112820.260966128083756999.davem@davemloft.net>
	<CALnjE+q65PHMBycfmE2L2DDYuVU_8HrAKJJUtzzjVDVkT+sinA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44748 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341Ab3GQGGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jul 2013 02:06:01 -0400
In-Reply-To: <CALnjE+q65PHMBycfmE2L2DDYuVU_8HrAKJJUtzzjVDVkT+sinA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin Shelar <pshelar@nicira.com>
Date: Tue, 16 Jul 2013 13:29:08 -0700

> commit 1c51a9159ddefa51 (vxlan: fix race caused by dropping
> rtnl_unlock) moved sock-create to sock_work workq. Thats why I thought
> sock_work takes RTNL. but if it is not taking RTNL in any case, they
> why vxlan sock create is deferred to sock_work?

That commit is handling the fact that the RTNL mutex is NOT held
during the create operation in question.

It defers to a workqueue so that the new ->sock_lock can be taken
in the appropriate context.
