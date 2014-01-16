From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 2/2] reciprocal_divide: correction/update of the algorithm
Date: Thu, 16 Jan 2014 01:46:42 +0100
Message-ID: <20140116004642.GJ19945@order.stressinduktion.org>
References: <1389828228-30312-1-git-send-email-dborkman@redhat.com> <1389828228-30312-3-git-send-email-dborkman@redhat.com> <1389831470.11912.40.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Austin S Hemmelgarn <ahferroin7@gmail.com>,
	Jesse Gross <jesse@nicira.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Matt Mackall <mpm@selenic.com>,
	Pekka Enberg <penberg@kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Jakub Zawadzki <darkjames-ws@darkjames.pl>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:41120 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751696AbaAPAqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 19:46:44 -0500
Content-Disposition: inline
In-Reply-To: <1389831470.11912.40.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 16, 2014 at 12:17:50AM +0000, Ben Hutchings wrote:
> On Thu, 2014-01-16 at 00:23 +0100, Daniel Borkmann wrote:
> [...]
> > --- a/include/linux/reciprocal_div.h
> > +++ b/include/linux/reciprocal_div.h
> [...]
> > + * RECIPROCAL_VALUE_TO_ZERO can be used to express an element, which
> > + * used as the argument to reciprocal_divide always yields zero.
> >   */
> [...]
> > +#define RECIPROCAL_VALUE_RESULT_TO_ZERO ((struct reciprocal_value){.sh1 = 32})
> [...]
> > +static inline u32 reciprocal_divide(u32 a, struct reciprocal_value R)
> >  {
> > -	return (u32)(((u64)A * R) >> 32);
> > +	u32 t = (u32)(((u64)a * R.m) >> 32);
> > +	return (t + ((a - t) >> R.sh1)) >> R.sh2;
> [...]
> 
> (a - t) has type u32.
> So (a - t) >> 32 has undefined behaviour.

Good catch, totally overlooked that.

Thanks,

  Hannes
