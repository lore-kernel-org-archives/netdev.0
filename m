From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] xfrm: dst_entries_init() per-net dst_ops
Date: Wed, 28 Oct 2015 14:42:43 +0100
Message-ID: <1446039763.132965.422568409.3FC44B03@webmail.messagingengine.com>
References: <1445962519-16133-1-git-send-email-dan.streetman@canonical.com>
 <CAOZ2QJMuPoSrrFdudiGYQ4PjvELbonqg94X2mQaUhZ-R5yS0hw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Dan Streetman <ddstreet@ieee.org>
To: Dan Streetman <dan.streetman@canonical.com>,
	Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOZ2QJMuPoSrrFdudiGYQ4PjvELbonqg94X2mQaUhZ-R5yS0hw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Wed, Oct 28, 2015, at 14:32, Dan Streetman wrote:
> On Tue, Oct 27, 2015 at 12:15 PM,  <dan.streetman@canonical.com> wrote:
> > From: Dan Streetman <dan.streetman@canonical.com>
> >
> > The ipv4 and ipv6 xfrms each create a template dst_ops object, and
> > perform dst_entries_init() on the template objects.  Then each net
> > namespace has its net.xfrm.xfrm[46]_dst_ops field set to the template
> > values.  The problem with that is the dst_ops.pcpuc_entries field is
> > a percpu counter and cannot be used correctly by simply copying it to
> > another object.

How hard would it be to split of the counters from the dst_ops struct?
We could make dst_ops instances const and have normal pointers to them
and keep the dst_entries as a small array in net namespace?

Bye,
Hannes
