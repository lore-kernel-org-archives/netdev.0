From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH] cipso: simplify cipso_v4_translate() when !CONFIG_NETLABEL
Date: Wed, 20 Nov 2013 14:45:19 -0500
Message-ID: <4007061.3MtKnenLV1@sifl>
References: <20131120192548.5616.74526.stgit@localhost> <20131120.143407.4095832971724166.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62171 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754628Ab3KTTpV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Nov 2013 14:45:21 -0500
In-Reply-To: <20131120.143407.4095832971724166.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, November 20, 2013 02:34:07 PM David Miller wrote:
> From: Paul Moore <pmoore@redhat.com>
> Date: Wed, 20 Nov 2013 14:25:48 -0500
> 
> > Previous commits corrected some problems with cipso_v4_translate()
> > when CONFIG_NETLABEL=n but some additional work is needed to tidy
> > things up a bit.
> > 
> > Signed-off-by: Paul Moore <pmoore@redhat.com>
> 
> That's really vague, please describe exactly what is wrong with the
> existing conditional and how you have fixed it.

I kinda figured the one line patch and "some additional work is needed to tidy 
things up a bit" summed it up nicely, but I guess not so here ya go ...

First, for reference, here is the diff one more time (some whitespace damage 
in the paste below for readability):

> diff --git a/include/net/cipso_ipv4.h b/include/net/cipso_ipv4.h
> index a8c2ef6..2244e02 100644
> --- a/include/net/cipso_ipv4.h
> +++ b/include/net/cipso_ipv4.h
> @@ -304,7 +304,7 @@ static inline int cipso_v4_validate(...)
>   for (opt_iter = 6; opt_iter < opt_len;) {   
>       tag_len = opt[opt_iter + 1];
> 
> -     if ((tag_len == 0) || (opt[opt_iter + 1] > (opt_len - opt_iter))) {
> +     if ((tag_len == 0) || (tag_len > (opt_len - opt_iter))) { 
>            err_offset = opt_iter + 1;
>            goto out;        
>       }

Looking at the original conditional:

 if ((tag_len == 0) || (opt[opt_iter + 1] > (opt_len - opt_iter))

... and the replacement:

 if ((tag_len == 0) || (tag_len > (opt_len - opt_iter)))

... we notice that "(opt[opt_iter + 1] > (opt_len - opt_iter))" has been 
replaced with "(tag_len > (opt_len - opt_iter))", substituting 'tag_len' for 
'opt[opt_iter + 1]'.  This is acceptable because the the first statement in 
the for loop is:

 tag_len = opt[opt_iter + 1]

... which matches the substitution in the conditional.  I'm not sure how much 
more explicit I can be about this change, it is really pretty minor.

-- 
paul moore
security and virtualization @ redhat
