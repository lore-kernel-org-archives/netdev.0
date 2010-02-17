From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [net-next PATCH v4 1/3] sysctl: refactor integer handling proc code
Date: Wed, 17 Feb 2010 23:09:14 +0200
Message-ID: <201002172009.14191.opurdila@ixiacom.com>
References: <1266271241-6293-1-git-send-email-opurdila@ixiacom.com> <201002161600.54975.opurdila@ixiacom.com> <4B7C19F1.9090106@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B7C19F1.9090106@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 17 February 2010 15:31:45 you wrote:

> >>>
> >>> What about the EFAULT check, is that really required?
> >>
> >> I think so, it means to keep the errno to user-space when it is EFAULT,
> >> right? This seems reasonable.
> >
> > The problem I see is that this way we don't actually acknowledge some of
> > the set values, e.g. say that we have buffer="1 2 3" and length = 100.
> > Although we do accept values 1, 2 and 3 we don't acknowledge that to the
> > user (as we would do for, say "1 2 3 4a"), but return -EFAULT.
> >
> > I think it would be better to skip this check. That means that the user
> > will get the ack for the 1, 2 and 3 values and next time it continues the
> > write it will get -EFAULT.
> >
> > This will of course change the userspace ABI, albeit in a minor way, and
> > it is not clear to me if doing this is allowed (even if this new approach
> > would be the correct one).
> 
> I think the right behavior is accept "1 2 3" and return the number of
> bytes that we accept.
> 

OK, it seems nobody is complaining about this corner case ABI change. I will 
remove the EFAULT check then. This will also help with making the code 
clearer, I hope.
