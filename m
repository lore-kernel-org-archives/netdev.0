From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next] qed: Add Light L2 [ll2] infrastructure
Date: Thu, 16 Jun 2016 05:27:30 +0000
Message-ID: <CO2PR11MB00883AFE474353EC5DA016B397560@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1465986157-16186-1-git-send-email-Yuval.Mintz@qlogic.com>
 <20160615.221701.587394586942508875.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0113.outbound.protection.outlook.com ([157.56.110.113]:31125
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751008AbcFPF1f convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 01:27:35 -0400
In-Reply-To: <20160615.221701.587394586942508875.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > The qed driver will allow support for several drivers other than qede,
> > and each of said protocol drivers will require some sort of L2-like
> > ability to send and receive traffic - the common use-case would be for
> > control traffic specific for the protocol that needs to reach
> > user/kernel tools, although other cases exist as well [some of which
> > are for internal use by firmware].
> 
> You have to describe in more detail who these users will be.
> 
> Actually, you are required to submit a use case along with any new facility and
> set of interfaces like this.
> 
> Otherwise it is impossible to review the facility and make sure it does what it is
> supposed to do, and is designed well for it's intended use case.

As I've mentioned in latest submissions, we're planning on pushing qedi and qedr
and both would utilize it. I agree the 'right' thing to do is probably to send this as
part of their submissions - we just wanted to minimize collisions since each one
of those drivers is going to add some content of its own to this file.

BTW, I'm not sure submitting this together with the using code would have made
much more sense - there's a really tight interface that can be used to manipulate
this:
+const struct qed_ll2_ops qed_ll2_ops_pass = {
+	.start = &qed_ll2_start,
+	.stop = &qed_ll2_stop,
+	.start_xmit = &qed_ll2_start_xmit,
+	.register_cb_ops = &qed_ll2_register_cb_ops,
+	.get_stats = &qed_ll2_stats,
+};
And most of the maintenance is held within the qed itself.
[The obvious con for sending it as part of the series submitting those protocol
Drivers is that it would become... monstrously long. You know, like the way we
like to submit to submit our series. ;-) ]

But I take your point; We'll submit this as part of those driver submissions.

Cheers,
Yuval
