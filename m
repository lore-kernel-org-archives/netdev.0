From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v7)
Date: Wed, 5 Aug 2009 08:29:48 -0500
Message-ID: <20090805132948.GA31272@us.ibm.com>
References: <1249331463-11887-1-git-send-email-danms@us.ibm.com> <1249331463-11887-6-git-send-email-danms@us.ibm.com> <20090804223141.GA14254@us.ibm.com> <8763d3dwmx.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, Alexey Dobriyan <adobriyan@gmail.com>,
	netdev@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:51339 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932964AbZHEN3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 09:29:47 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e39.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n75DOxc0006805
	for <netdev@vger.kernel.org>; Wed, 5 Aug 2009 07:24:59 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n75DTlua255126
	for <netdev@vger.kernel.org>; Wed, 5 Aug 2009 07:29:47 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n75DTk94011976
	for <netdev@vger.kernel.org>; Wed, 5 Aug 2009 07:29:47 -0600
Content-Disposition: inline
In-Reply-To: <8763d3dwmx.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Dan Smith (danms@us.ibm.com):
> SH> why only free iov_base if ret!=0?
> 
> Because I was diagnosing a crash that only seemed to happen when I
> free()'d the buffer after it was used by sendmsg() and I forgot to
> remove this :(
> 
> >> +	a->sk_peercred.pid = task_tgid_vnr(current);
> >> +	a->sk_peercred.uid = ctx->realcred->uid;
> 
> SH> I don't know how much it matters, but of course root could be
> SH> restarting a set of tasks owned by several non-root uids, and the
> SH> peercred.uid's might need to be something other than
> ctx-> realcred->uid.  Or not?
> 
> Oh, so you're suggesting I use ctx->ecred instead?  I didn't actually
> notice the double declaration in the ckpt_ctx, but I guess that would
> be better.

No, I'm suggesting that the checkpointed application might have had
tasks owned by uids 0, 3, 55, and 1001, and a.peercred.uid might have
been 1001, right?  current, ctx->realcred->uid, and ctx->ecred might
all be different uids.  I think you just need to checkpoint the uid
(eventually an objref to a checkpointed user struct so we can also
catch the user namespace).

-serge
