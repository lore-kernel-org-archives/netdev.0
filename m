From: John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support
 for datapath hardware offload
Date: Sun, 24 Aug 2014 19:42:42 -0700
Message-ID: <53FAA2A2.7070801@gmail.com>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
 <1408637945-10390-11-git-send-email-jiri@resnulli.us>
 <53F79C54.5050701@gmail.com>
 <464DB0A8-0073-4CE0-9483-0F36B73A53A1@cumulusnetworks.com>
 <53F9459B.2070801@mojatatu.com> <20140824111218.GA32741@casper.infradead.org>
 <53FA01AC.10507@mojatatu.com>
 <A67C7591-19BF-4431-9119-F61361F5E618@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; Format="flowed"
Content-Transfer-Encoding: quoted-printable
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
 Andy Gospodarek <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org,
 f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 ogerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org, buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org,
 Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
 Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, dborkman <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Scott Feldman <sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <A67C7591-19BF-4431-9119-F61361F5E618-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
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

On 08/24/2014 07:24 PM, Scott Feldman wrote:
>
> On Aug 24, 2014, at 8:15 AM, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org> wrote:
>
>> On 08/24/14 07:12, Thomas Graf wrote:
>>> On 08/23/14 at 09:53pm, Jamal Hadi Salim wrote:
>>
>>>
>>> I get what you are saying but I don't see that to be the case here. I
>>> don't see how this series proposes the OVS case as *the* interface.
>>
>> The focus of the patches is on offloading flows (uses the
>> ovs or shall i say the broadcom OF-DPA API, which is one
>> vendor's view of the world).
>>
>> Yes, people are going to deploy more hardware which knows how to do
>> a lot of flows (but today that is in the tiny tiny minority)
>>
>> I would have liked to see more focus on L2/3 as a first step because
>> they are more predominantly deployed than anything with flows. And
>> they are well understood from a functional perspective.
>> Then that would bring to the front API issues since you have
>> a large sample space of deployments and we can refactor as needed.
>
> With respect to focus on L2/L3, I have a pretty *good* hunch someone
could write a kernel module that gleans from the L2/L3 netlink echoes
already flying around and translates to sw_flows and in turn into
ndo_swdev_flow_* calls. So the existing linux bonds and bridges and
vlans and ROUTEs and NEIGHs and LINKs and ADDRs work as normal,
unchanged, with iproute2 still originating the netlink msgs from the
user. The new kernel module (let=92s call it =93dagger=94 after the white s=
py
from spy vs. spy MAD comic) can figure out what forwarding gets
offloaded to HW just from the netlink echoes. If someone wrote a dagger
module in parallel with the other efforts being discussed here, I think
we=92d have a pretty good idea what the API needs to look like, at least
to cover existing L2/L3 world we're all familiar with. Gleaning netlink
msgs isn=92t ideal for several reasons (and probably making more than a
few in the audience squeamish), but it would be a quick way to get us
closer to the answer we=92re seeking which is the swdev driver model.
>

In the L2 case we already have the fdb_add and fdb_del semantics that
are being used today by NICs with embedded switches. And we have a DSA
patch we could dig out of patchwork for those drivers.

So I think it makes more sense to use the explicit interface rather
than put another shim layer in the kernel. Its simpler and more to the
point IMO. I suspect the resulting code will be smaller and easier to
read. I'm the squemish one in the audience here.

.John


-- =

John Fastabend         Intel Corporation
