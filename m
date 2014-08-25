From: Scott Feldman <sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support
	for datapath hardware offload
Date: Sun, 24 Aug 2014 19:24:20 -0700
Message-ID: <A67C7591-19BF-4431-9119-F61361F5E618@cumulusnetworks.com>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
 <1408637945-10390-11-git-send-email-jiri@resnulli.us>
 <53F79C54.5050701@gmail.com>
 <464DB0A8-0073-4CE0-9483-0F36B73A53A1@cumulusnetworks.com>
 <53F9459B.2070801@mojatatu.com> <20140824111218.GA32741@casper.infradead.org>
 <53FA01AC.10507@mojatatu.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
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
To: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <53FA01AC.10507-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
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


On Aug 24, 2014, at 8:15 AM, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org> wrote:

> On 08/24/14 07:12, Thomas Graf wrote:
>> On 08/23/14 at 09:53pm, Jamal Hadi Salim wrote:
> =

>> =

>> I get what you are saying but I don't see that to be the case here. I
>> don't see how this series proposes the OVS case as *the* interface.
> =

> The focus of the patches is on offloading flows (uses the
> ovs or shall i say the broadcom OF-DPA API, which is one
> vendor's view of the world).
> =

> Yes, people are going to deploy more hardware which knows how to do
> a lot of flows (but today that is in the tiny tiny minority)
> =

> I would have liked to see more focus on L2/3 as a first step because
> they are more predominantly deployed than anything with flows. And
> they are well understood from a functional perspective.
> Then that would bring to the front API issues since you have
> a large sample space of deployments and we can refactor as needed.

With respect to focus on L2/L3, I have a pretty *good* hunch someone could =
write a kernel module that gleans from the L2/L3 netlink echoes already fly=
ing around and translates to sw_flows and in turn into ndo_swdev_flow_* cal=
ls.  So the existing linux bonds and bridges and vlans and ROUTEs and NEIGH=
s and LINKs and ADDRs work as normal, unchanged, with iproute2 still origin=
ating the netlink msgs from the user.  The new kernel module (let=92s call =
it =93dagger=94 after the white spy from spy vs. spy MAD comic) can figure =
out what forwarding gets offloaded to HW just from the netlink echoes.  If =
someone wrote a dagger module in parallel with the other efforts being disc=
ussed here, I think we=92d have a pretty good idea what the API needs to lo=
ok like, at least to cover existing L2/L3 world we're all familiar with.  G=
leaning netlink msgs isn=92t ideal for several reasons (and probably making=
 more than a few in the audience squeamish), but it would be a quick way to=
 get us closer to the answer we=92re seeking which is the swdev driver mode=
l.

-scott
