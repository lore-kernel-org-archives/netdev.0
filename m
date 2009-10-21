From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] net: allow netdev_wait_allrefs() to run faster
Date: Wed, 21 Oct 2009 19:55:39 +0300
Message-ID: <200910211955.40084.opurdila@ixiacom.com>
References: <20091017221857.GG1925@kvack.org> <200910211539.01824.opurdila@ixiacom.com> <4ADF2B57.4030708@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Benjamin LaHaise <bcrl@lhnet.ca>, netdev@vger.kernel.org,
	Cosmin Ratiu <cratiu@ixiacom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:13180 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753661AbZJUQ6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 12:58:30 -0400
In-Reply-To: <4ADF2B57.4030708@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 21 October 2009 18:40:07 you wrote:

> >
> > I would also like to see this patch in, we are running into scalability
> > issues with creating/deleting lots of interfaces as well.
> 
> Ben patch only address interface deletion, and one part of the problem,
> maybe the more visible one for the current kernel.
> 
> Adding lots of interfaces only needs several threads to run concurently.
> 
> Before applying/examining his patch I suggest identifying all dev_put()
>  spots than can be deleted and replaced by something more scalable. I began
>  this job but others can help me.
> 

Yes, I agree with you, there are multiple places which needs to be touched to 
allow for better scaling with regard to the number of interfaces. We do have 
patches that addresses some of these issues, but unfortunately they are based 
on 2.6.7 and some of them are quite ugly hacks :) 

However, we are in the process of switching to 2.6.31 so I hope we will be 
able to contribute on this effort.

> RTNL and rcu grace periods are going to hurt anyway, so you probably need
> to use many tasks to be able to delete lots of interfaces in parallel.
> 

Hmm, how would multiple tasks help here? Isn't the RTNL mutex global?

> netdev_run_todo() should also use a better algorithm to allow parallelism.
> 
> Following patch doesnt slow down dev_put() users and real scalability
> problems will surface and might be addressed.
> 
> [PATCH] net: allow netdev_wait_allrefs() to run faster
> 

Thanks, I am going to test it on our platform and send back the results.

tavi
