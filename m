From: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support
 for datapath hardware offload
Date: Sat, 23 Aug 2014 21:53:31 -0400
Message-ID: <53F9459B.2070801@mojatatu.com>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
 <1408637945-10390-11-git-send-email-jiri@resnulli.us>
 <53F79C54.5050701@gmail.com>
 <464DB0A8-0073-4CE0-9483-0F36B73A53A1@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; Format="flowed"
Content-Transfer-Encoding: quoted-printable
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org,
 buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org, Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
 roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org,
 vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Scott Feldman <sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
 John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <464DB0A8-0073-4CE0-9483-0F36B73A53A1-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
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

On 08/22/14 18:53, Scott Feldman wrote:

Ok, Scott - now i have looked at the patches on the plane and i am
still not convinced ;->

> The intent is to use openvswitch.ko=92s struct sw_flow to program hardwar=
e via the
>ndo_swdev_flow_* ops, but otherwise be independent of OVS.  So the upper l=
ayer of
>the driver is struct sw_flow and any module above the driver can construct=
 a struct
>sw_flow and push it down via ndo_swdev_flow_*.  So your non-OVS use-case s=
hould be
>handled.  OVS is another use-case.  struct sw_flow should not be OVS-aware=
, but
>rather a generic flow match/action sufficient to offload the data plane to=
 HW.


There is a legitimate case to be made for offloading OVS but *not*
a basis for making it the offload interface.
My suggestion is to make all OVS stuff a separate patchset.
This thing needs to stand alone without OVS and we dont need
to confuse the two.

Having said that:
I believe in starting simple - by solving the basic functions of
L2/3 offload first because those are well understood and fundamental.
There is the simplicity of those network functions and then
need to deal with tons of quarks that surround them....
I think getting that right will help in understanding the issues and
make this interface better. This is where i am going to focus my effort.

Here's my view on flows in the patchset:
What we need is ability to specify different types of classifiers.
But leave L2 and 3 out of that - that should be part of the basic
feature set.
Your 15-tuple classifier should be one of those classifiers.
This is because you *cannot possibly* have a universal classifier.
The tc classifier/action API has got this part right. There is
no ONE flow classifier but rather it has flexibility to add as many
as you want.
IOW:
I should be able to specify a classifier that matches the
definition of the openflow thing you are using. But then i should also
be able to create one based on 32 bit value/masks, one that classifies
strings, one that classifies metadata, my own pigeon observer
classifier etc. And be able to attach them in combinations
to select different things within the packet and act differently.

Lets pick an example of the u32 classifier (or i could pick nftables).
Using your scheme i have to incur penalties to translating u32 to your
classifier and only achieve basic functionality; and now in addition
i cant do 90% of my u32 features. And u32 is very implementable
in hardware.

cheers,
jamal
