From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v3 net-next 1/3] ipv4: rename ip_options_echo to
 __ip_options_echo()
Date: Fri, 26 Sep 2014 01:08:05 -0700
Message-ID: <1411718885.19443.2.camel@joe-AO725>
References: <1411676092-16196-1-git-send-email-edumazet@google.com>
	 <1411676092-16196-2-git-send-email-edumazet@google.com>
	 <1411677008.3460.7.camel@joe-AO725>
	 <1411677484.16953.43.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411678163.3460.9.camel@joe-AO725>
	 <alpine.DEB.2.02.1409260724520.2078@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Christoph Paasch <christoph.paasch@uclouvain.be>
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0083.hostedemail.com ([216.40.44.83]:54757 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753540AbaIZIIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 04:08:12 -0400
In-Reply-To: <alpine.DEB.2.02.1409260724520.2078@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-26 at 07:29 +0200, Julia Lawall wrote:
> On Thu, 25 Sep 2014, Joe Perches wrote:
> > On Thu, 2014-09-25 at 13:38 -0700, Eric Dumazet wrote:
> > > On Thu, 2014-09-25 at 13:30 -0700, Joe Perches wrote:
[]
> > > > I wonder how much effort, if any, should be made to convert
> > > > struct sk_buff * to const struct sk_buff * where appropriate.
> > > > 
> > > > For instance:n
> > > > 
> > > > This __ip_options_echo could use const struct sk_buff *skb
> > > > if fib_compute_spec_dst was changed to const struct sk_buff *skb.
> > > 
> > > Well, this seems something certainly doable, as a follow up ;)
> > 
> > It's doable, but it seems a non-trivial inspection task.
> > 
> > I believe coccinelle does not have the ability to automate this.
> 
> What are the exact conditions when the change is possible?
> 
> I guess something like the value is only used for accessing its fields. 
> and is not passed to any other function?

I expect the entire call tree needs to be known
and inspected for modification of fields.
