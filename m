From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 6/6] net_sched: make macro be enclosed in parenthesis
Date: Wed, 11 Dec 2013 10:20:32 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B747A@saturn3.aculab.com>
References: <1386680134-85452-1-git-send-email-yangyingliang@huawei.com><1386680134-85452-7-git-send-email-yangyingliang@huawei.com> <20131210.224900.1427512059771492387.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>, <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:54271 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751009Ab3LKKVf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 05:21:35 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 06490-07 for <netdev@vger.kernel.org>;
 Wed, 11 Dec 2013 10:21:31 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20131210.224900.1427512059771492387.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of David Miller
> From: Yang Yingliang <yangyingliang@huawei.com>
> Date: Tue, 10 Dec 2013 20:55:34 +0800
> 
> > Macros with complex values should be enclosed in parenthesis
> >
> > Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> > ---
> >  net/sched/em_meta.c | 4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> >
> > diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
> > index e5cef956..852cd62 100644
> > --- a/net/sched/em_meta.c
> > +++ b/net/sched/em_meta.c
> > @@ -272,10 +272,12 @@ META_COLLECTOR(int_rtiif)
> >   **************************************************************************/
> >
> >  #define SKIP_NONLOCAL(skb)			\
> > +({						\
> >  	if (unlikely(skb->sk == NULL)) {	\
> >  		*err = -1;			\
> >  		return;				\
> > -	}
> > +	}					\
> > +})
> 
> I can't apply this.
> 
> First of all, "({ })" is for statements that evaluate to an lvalue,
> this macro does not.
> 
> Second of all, and more importantly, this macro needs to be eliminated
> entirely.  It completely hides control flow, and in the past we've
> killed macros which do this such as the old netlink attribute
> builders.
> 
> The control flow should be inlined and expanded explicitly in the
> code so that someone who reads it can tell the control flow can
> be changed by the statement.  Compare:
> 
> 	SKIP_NONLOCAL(skb)
> 
> to:
> 
> 	if (skip_nonlocal(skb)) {
> 		*err = -1;
> 		return;
> 	}

Or:
	if (!skb->sk)
		goto no_sk;
	...
	return;

no_sk:
	*err = -1;
	return;

Actually WTF is a void function doing having an 'int *err' argument?
These should just be:
	if (!skb->sk)
		return -1;

	David
