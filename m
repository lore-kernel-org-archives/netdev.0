From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] netpoll: Fix extra refcount release in
 netpoll_cleanup()
Date: Fri, 25 Mar 2016 15:16:36 -0400 (EDT)
Message-ID: <20160325.151636.590435237623997861.davem@davemloft.net>
References: <20160325025621.32476.93348.stgit@bhelgaas-glaptop2.roam.corp.google.com>
	<20160325113342.GA21579@hmsreliant.think-freely.org>
	<20160325164639.GA29822@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@redhat.com, bhelgaas@google.com,
	nikolay@cumulusnetworks.com, netdev@vger.kernel.org,
	aduyck@mirantis.com, linux-kernel@vger.kernel.org
To: helgaas@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160325164639.GA29822@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bjorn Helgaas <helgaas@kernel.org>
Date: Fri, 25 Mar 2016 11:46:39 -0500

> You're right, there is an issue here.  I reproduced a problem with a
> bond device.  bond_netpoll_setup() calls __netpoll_setup() directly
> (not netpoll_setup()).  I'll debug it more; just wanted to let you
> know there *is* a problem with this patch.

I bet that's why the assignment to np->dev and the reference counting
were separated in the first place :-/

Indeed, commit 30fdd8a082a00126a6feec994e43e8dc12f5bccb:

commit 30fdd8a082a00126a6feec994e43e8dc12f5bccb
Author: Jiri Pirko <jiri@resnulli.us>
Date:   Tue Jul 17 05:22:35 2012 +0000

    netpoll: move np->dev and np->dev_name init into __netpoll_setup()
    
    Signed-off-by: Jiri Pirko <jiri@resnulli.us>
    Signed-off-by: David S. Miller <davem@davemloft.net>
