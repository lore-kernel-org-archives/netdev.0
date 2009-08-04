From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v7)
Date: Tue, 04 Aug 2009 15:47:34 -0700
Message-ID: <8763d3dwmx.fsf@caffeine.danplanet.com>
References: <1249331463-11887-1-git-send-email-danms@us.ibm.com>
	<1249331463-11887-6-git-send-email-danms@us.ibm.com>
	<20090804223141.GA14254@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, Alexey Dobriyan <adobriyan@gmail.com>,
	netdev@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:40032 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933440AbZHDWre (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 18:47:34 -0400
In-Reply-To: <20090804223141.GA14254@us.ibm.com> (Serge E. Hallyn's message of "Tue\, 4 Aug 2009 17\:31\:41 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SH> why only free iov_base if ret!=0?

Because I was diagnosing a crash that only seemed to happen when I
free()'d the buffer after it was used by sendmsg() and I forgot to
remove this :(

>> +	a->sk_peercred.pid = task_tgid_vnr(current);
>> +	a->sk_peercred.uid = ctx->realcred->uid;

SH> I don't know how much it matters, but of course root could be
SH> restarting a set of tasks owned by several non-root uids, and the
SH> peercred.uid's might need to be something other than
ctx-> realcred->uid.  Or not?

Oh, so you're suggesting I use ctx->ecred instead?  I didn't actually
notice the double declaration in the ckpt_ctx, but I guess that would
be better.

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
