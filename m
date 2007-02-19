From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH 1/2] RTNL and flush_scheduled_work deadlocks
Date: Mon, 19 Feb 2007 08:40:47 +0100
Message-ID: <20070219074046.GB1900@ff.dom.local>
References: <20070216072928.GA1599@ff.dom.local> <45D55FF0.8090309@candelatech.com> <20070216103115.517f1a4c@freekitty> <45D60022.9060701@candelatech.com> <20070219061300.GA1640@ff.dom.local> <45D94347.8060405@candelatech.com> <20070219071159.GB1686@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Kyle Lucke <klucke@us.ibm.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Al Viro <viro@ftp.linux.org.uk>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:40213 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750719AbXBSHhY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 02:37:24 -0500
Content-Disposition: inline
In-Reply-To: <20070219071159.GB1686@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 19, 2007 at 08:11:59AM +0100, Jarek Poplawski wrote:
> On Sun, Feb 18, 2007 at 10:27:19PM -0800, Ben Greear wrote:
..
> > You are also changing the semantics of ASSERT_RTNL (assert *this thread* 
> > has rtnl, from the
> > old behaviour:  assert *some thread* has rtnl).  It may be better this
> > way, but it could break code that assumes the old behaviour.

If any code could assume the old behaviour it's simply
a bug (eg. doing ASSERT_RTNL two times one after
another could give different results). And it's
logically wrong to: the same process is trying to
acquire the same lock second time (pseudo recursively:
it makes difficult lock verifying eg. by lockdep). 

Jarek P.
