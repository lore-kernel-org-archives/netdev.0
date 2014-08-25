From: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support
 for datapath hardware offload
Date: Mon, 25 Aug 2014 12:15:30 -0400
Message-ID: <53FB6122.2040901@mojatatu.com>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
 <1408637945-10390-11-git-send-email-jiri@resnulli.us>
 <53F79C54.5050701@gmail.com>
 <464DB0A8-0073-4CE0-9483-0F36B73A53A1@cumulusnetworks.com>
 <53F9459B.2070801@mojatatu.com> <20140824111218.GA32741@casper.infradead.org>
 <53FA01AC.10507@mojatatu.com>
 <A67C7591-19BF-4431-9119-F61361F5E618@cumulusnetworks.com>
 <53FAA2A2.7070801@gmail.com> <53FB3FD5.2030905@mojatatu.com>
 <20140825141754.GA30140@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
 Andy Gospodarek <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org,
 f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ogerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
 ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org, buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org, Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
 roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org,
 vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org,
 dborkman <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20140825141754.GA30140-FZi0V3Vbi30CUdFEqe4BF2D2FQJk+8+b@public.gmane.org>
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

On 08/25/14 10:17, Thomas Graf wrote:
> On 08/25/14 at 09:53am, Jamal Hadi Salim wrote:

> fdb_add() *is* flow based. At least in my understanding, the whole
> point here is to extend the idea of fdb_add() and make it understand
> L2-L4 in a more generic way for the most common protocols.
>
> The reason fdb_add() is not reused is because it is Netlink specific
> and only suitable for User -> HW offload. Kernel -> HW offload is
> technically possible but not clean.
>

I dont think we have a problem handling any of this today.


> The only reason swdev is needed at all is to represent the port model
> and to allow for non flow based models built on top of the same
> hardware abstraction. I see now reason why br_fdb cannot be represented
> through swdev as soon as the code is stable.
>

This is where our (shall i say strong) disagreement is.
I think you will find it non-trivial to show me how you can
actually take the simple L2 bridge and map it to a "flow".
Since your starting point is "everything can be represented via a flow
and some table" - we are at a crosspath.

> The point I was trying to make earlier is that it is very hard to
> program both protocol aware and generic filtering hardware through
> a single NDO. It will make the driver specific part complex.
>

The tc filter API seems to be doing just that.
You have different types of classifiers - the h/w may not be able
to support some classifier types - but that is a capability discovery
challenge.

> If you are saying we need yet another classifier model in the kernel
> then I'm not sure that is needed in the presence of cls/act, iptables,
> and nftables. They seem suitable to represent non flow based models
> and I see nothing that would prevent an offload through swdev for them.
>

I am saying two things:
1) There are a few "fundamental" interfaces; L2 and L3 being some.
Add crypto offload and a few i mentioned in  my presentation. We
know how to do those. example; there is nothing i cant do with
the rtmsg that is L3. or the fdb/port/vlan filter for L2.
This flow thing should stay out of those.

2) The flow thing should allow a variety of classifiers to be
handled. Again capability discovery would take care of differences.

cheers,
jamal
