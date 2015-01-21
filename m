From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 7/9] rhashtable: Per bucket locks & deferred
 expansion/shrinking
Date: Tue, 20 Jan 2015 21:29:07 -0800
Message-ID: <20150121052907.GY9719@linux.vnet.ibm.com>
References: <20150116161530.GC15052@casper.infradead.org>
 <20150116163202.GJ30132@acer.localdomain>
 <063D6719AE5E284EB5DD2968C1650D6D1CACADAF@AcuExch.aculab.com>
 <20150116165302.GE15052@casper.infradead.org>
 <20150116183626.GS30132@acer.localdomain>
 <20150116191831.GA26730@casper.infradead.org>
 <20150116193557.GU30132@acer.localdomain>
 <20150116204644.GA2232@salvia>
 <20150119090121.GG9719@linux.vnet.ibm.com>
 <20150121052333.GA23382@gondor.apana.org.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>, Thomas Graf <tgraf@suug.ch>,
	David Laight <David.Laight@ACULAB.COM>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"edumazet@google.com" <edumazet@google.com>,
	"john.r.fastabend@intel.com" <john.r.fastabend@intel.com>,
	"josh@joshtriplett.org" <josh@joshtriplett.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:43629 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294AbbAUF3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 00:29:14 -0500
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 20 Jan 2015 22:29:13 -0700
Content-Disposition: inline
In-Reply-To: <20150121052333.GA23382@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 21, 2015 at 04:23:33PM +1100, Herbert Xu wrote:
> On Mon, Jan 19, 2015 at 01:01:21AM -0800, Paul E. McKenney wrote:
> >
> > One unconventional way of handling this is to associate the scan with
> > a one-to-one resize operation.  This can be implemented to have the
> > effect of taking a snapshot of the table.
> 
> The problem is that in general (not for netfilter, but certainly
> other rhashtable users such as netlink) dumps/walks can be started
> by ordinary users and I don't think we can afford creating a
> snapshot for each one, or can we?

Well, you -could- batch them up, so that a single snapshot covered
several users, and once that set was done and memory reclaimed, a second
snapshot could cover any additional users that requested dumps/walks in
the meantime.  Or are users allowed to walk arbitrarily slowly through
the table?

							Thanx, Paul
