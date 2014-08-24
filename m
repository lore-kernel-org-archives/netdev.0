From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support
 for datapath hardware offload
Date: Sun, 24 Aug 2014 12:32:19 +0100
Message-ID: <20140824113219.GB32741@casper.infradead.org>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
 <1408637945-10390-11-git-send-email-jiri@resnulli.us>
 <53F79C54.5050701@gmail.com>
 <464DB0A8-0073-4CE0-9483-0F36B73A53A1@cumulusnetworks.com>
 <20140823092458.GC1854@nanopsycho.orion>
 <20140823145126.GB24116@casper.infradead.org>
 <53F8CAB9.8080407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org,
 buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org, Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
 roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org, aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <53F8CAB9.8080407-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 08/23/14 at 10:09am, John Fastabend wrote:
> Right. I think this is basically what Jiri and I discussed when he
> originally posted the series. For my use cases this is one of the
> more interesting pieces. If no one else is looking at it I can try
> it on some of the already existing open source drivers that have some
> very simple support for ingress flow tables read flow director.

Awesome. I'm definitely very interested in helping out on this part
as well.

> Thanks. This is exactly what I was trying to hint at and why the
> optimization can not be done in the driver. The driver shouldn't
> have to know about the cost models of SW vs HW rules or how to
> break up rules into sets of complimentary hw/sw rules.

That's an excellent summary of what I wanted to say.

> the other thing I've been thinking about is how to handle hardware
> with multiple flow tables. We could let the driver handle this
> but if I ever want to employ a new optimization strategy then I
> need to rewrite the driver. To me this looks a lot like policy
> which should not be driven by the kernel. We can probably ignore
> this case for the moment until we get some of the other things
> addressed.

Agreed, this sounds like something to handle a bit later.
It is potentially very interesting as it would allow to offload at
least partial pipelines but it obviously adds a new dimension to
the API. I strongly feel that the API as proposed could be extended
in this direction though. It will require a notion of tables for
swdev_flow_insert() and we'll likely need an API to set default
table policies although that is likely even needed for single table
support. We might also have to introduce a concept of bundles at
some point to provide atomic updates across multiple tables for
consistency.

> IMO I think extending the API is the easiest route but the best
> way to resolve this is to try and write the code. I'll take a
> stab at it next week.

I'm absolutely interested in writing code for this as well. If we
can find consensus on merging at least the core API bits in some
form then that would allow for more people to get involved. Maybe
we can skip the OVS bits in the first merge and continue that work
in a separate git tree. I'm also definitely very interested in hearing
Pravin's and Jesse's thoughts on the overall API ;-)

John's flow director API replacement idea can definitely serve as an
excellent first in-tree consumer as it looks even simpler.

> by the way Jiri I think the patches are a great start.

+1
