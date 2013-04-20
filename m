From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: net: fix incorrect credentials passing
Date: Sat, 20 Apr 2013 03:53:50 -0700
Message-ID: <87ip3h4gn5.fsf@xmission.com>
References: <alpine.LFD.2.03.1304191826080.2455@gmail.com>
	<20130419.215856.1499421731544629706.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	serge@hallyn.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:33197 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754794Ab3DTKyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Apr 2013 06:54:03 -0400
In-Reply-To: <20130419.215856.1499421731544629706.davem@davemloft.net> (David
	Miller's message of "Fri, 19 Apr 2013 21:58:56 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Fri, 19 Apr 2013 18:32:32 -0700 (PDT)
>
>> Commit 257b5358b32f ("scm: Capture the full credentials of the scm 
>> sender") changed the credentials passing code to pass in the effective 
>> uid/gid instead of the real uid/gid.
>
> Yep, that's exactly what happened, via a very twisty and winding road.
>
> The helper cred_to_ucred(), which was created by commit
> 3f551f9436c05a3b5eccdd6e94733df5bb98d2a5 ("sock: Introduce
> cred_to_ucred") seemed to be aimed at providing the semantics expected
> by SO_PEERCRED, which does in fact want to use the effective UIDs and
> GIDs.
>
> The SO_PEERCRED side of this can be seen more clearly in commit
> 109f6e39fa07c48f580125f531f46cb7c245b528 ("af_unix: Allow SO_PEERCRED
> to work across namespaces.")
>
> The error begins when we try to use that helper in the SCM credentials
> code.
>
> Initially, cred_to_ucred() is what was used by scm_set_cred().  Then
> it got changed in dbe9a4173ea53b72b2c35d19f676a85b69f1c9fe ("scm:
> Don't use struct ucred in NETLINK_CB and struct scm_cookie.") which
> continues the error by propagating the effective UID/GID usage from
> cred_to_ucred() into explicit accesses inside of scm_set_cred().
>
> So, as stated, the error originates from trying to use this common
> helper for both SO_PEERCERD and the SCM stuff, the latter of which
> does not want to use effective UIDs and GIDs.
>
>> This just undoes that (presumably unintentional) part of the commit.
>
> Indeed, I'd say this was an oversight in semantic differences when
> creating the cred_to_ucred() helper.
>
> Eric B. please review and ACK this.

I have followed this only briefly and looked at this only quickly but I
David I read the git history the same way you do.  I introduced a
behavior change when the cred_to_ucred helper was introduced into
scm_set_cred().  Linus's patch restores the original behavior.

So.

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

Hopefully that is sufficient.  I am in the midst of taking care of some
non-software things this week and I really don't have the time to look
more closely.

Eric
