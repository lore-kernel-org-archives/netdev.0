From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: [PATCH 02/15] user ns: setns: move capable checks into per-ns
 attach helper
Date: Fri, 9 Sep 2011 14:56:36 +0000
Message-ID: <20110909145636.GA24954@hallyn.com>
References: <1314993400-6910-1-git-send-email-serge@hallyn.com>
 <1314993400-6910-5-git-send-email-serge@hallyn.com>
 <20110904015140.GB32295@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, segooon@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	dhowells@redhat.com, ebiederm@xmission.com, rdunlap@xenotime.net
To: Matt Helsley <matthltc@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110904015140.GB32295@count0.beaverton.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Matt Helsley (matthltc@us.ibm.com):
> On Fri, Sep 02, 2011 at 07:56:27PM +0000, Serge Hallyn wrote:
> > From: "Serge E. Hallyn" <serge@hallyn.com>
> 
> I was confused about this patch until I realized that you're not
> simply "moving" the capability checks but "distributing" them. Then
> you're showing that you'll soon change some to nsown_capable() or
> ns_capable() using the strange cpp pattern in the snippet below.
> 
> At least I think that's what you intended. A commit message would
> help :).

Yes, sorry - Eric convinced me several times to be more conservative in
the patch, and I failed to fix the commit msg when squashing the
resulting patches.  How about the following:

======

user ns: update capable calls when cloning and attaching namespaces

Distribute the capable() checks at ns attach into the namespace-specific
attach handler.

Note the fact that the capable() checks will be changed to targeted
checks at both namespace clone and attach methods, but don't actually
make that change yet.  Until that trigger is pulled, you must have
the capabilities targeted toward the initial user namespace in order to
do any of these actions, meaning that a task in a child user namespace
cannot do them.  Once we pull the trigger, a task in a child user
namespace will be able to clone new namespaces if it is privileged in
its own user namespace, and attach to existing namespaces to which it
has privilege.

======

Thanks for taking a look, Matt!

-serge
