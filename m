From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] improved xfrm_audit_log() patch
Date: Wed, 22 Aug 2007 20:05:02 -0700 (PDT)
Message-ID: <20070822.200502.35874480.davem@davemloft.net>
References: <20070821.002405.88473654.davem@davemloft.net>
	<20070822.125157.43008100.davem@davemloft.net>
	<1187832557.15699.687.camel@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com
To: latten@austin.ibm.com
Return-path: <linux-audit-bounces@redhat.com>
In-Reply-To: <1187832557.15699.687.camel@faith.austin.ibm.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

From: Joy Latten <latten@austin.ibm.com>
Date: Wed, 22 Aug 2007 20:29:17 -0500

> On Wed, 2007-08-22 at 12:51 -0700, David Miller wrote:
> > From: David Miller <davem@davemloft.net>
> > Date: Tue, 21 Aug 2007 00:24:05 -0700 (PDT)
> > 
> > > Looks good, applied to net-2.6.24, thanks Joy.
> > 
> > Something is still buggered up in this patch, you can't add this local
> > "audit_info" variable unconditionally to these functions, and
> > alternatively you also can't add a bunch of ifdefs to xfrm_user.c to
> > cover it up either.
> > 
> I wonder if I am subconsciously trying to break a record or 
> something! My apologies as time is valuable. 
> 
> I mean to get this right. My rationale for using audit_info was to
> reduce amount of arguments to xfrm_audit_log(). However, I now like
> it better when I just called xfrm_audit_log(NETLINK_CB(skb).loginuid,
> NETLINK_CB(skb).sid, ...). User determines where/how to get loginuid and
> secid and nothing happens when AUDIT not configured. But would make
> xfrm_audit_log() have 7 arguments instead of 6.
> 
> My alternative is to remove xfrm_get_auditinfo() out of the 
> #ifdef CONFIG_AUDITSYSCALL and always fill in audit_info
> regardless if AUDIT is configured or not. Less calls to
> xfrm_audit_log() but perhaps unnecessary info when AUDIT 
> not configured.
> 
> Would first solution be acceptable?

I don't like either of these ideas, sorry.

I would suggest, at this point, to make purpose built situation
specific interfaces that pass specific objects (the ones being
operated upon) to the audit layer.

Let the audit layer pick out the bits it actually wants in the
format it likes.

For example, if we're creating a template, pass the policy and
the templace to the audit layer via a function called:

xfrm_audit_template_add()

or something like that.  That function only needs two arguments.

All of these call sites will rarely need more than 2 or 3 arguments in
any given situation, and the on-stack audit thing will be gone too.

This is the suggestion I made to you over a month ago, but you choose
to do the on-stack thing.

You must make this cost absolutely nothing when it is either
not configured, and have next to no cost when not enabled at
run time.  And it is very doable.
