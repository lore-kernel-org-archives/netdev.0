From: Scott Feldman <sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support
	for datapath hardware offload
Date: Fri, 5 Sep 2014 00:02:03 -0700
Message-ID: <E3C7797F-081E-484F-918E-937C705B43D6@cumulusnetworks.com>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
 <1408637945-10390-11-git-send-email-jiri@resnulli.us>
 <20140904090447.GB3176@vergenet.net>
 <F4498A89-C1D6-4C5A-A6F0-942015D36B77@cumulusnetworks.com>
 <20140905040810.GB32481@vergenet.net>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: Sergey Ryazanov <ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org,
 Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andy Gospodarek <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
 Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, ogerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
 Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
 Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>, Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
 Roopa Prabhu <roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
 Aviad Raveh <aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org,
 Vlad Yasevich <vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>, dborkman <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, David Miller <dav
To: Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20140905040810.GB32481-IxS8c3vjKQDk1uMJSBkQmQ@public.gmane.org>
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


On Sep 4, 2014, at 9:08 PM, Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org> wrote:

> On Thu, Sep 04, 2014 at 09:30:45AM -0700, Scott Feldman wrote:
>> =

>> On Sep 4, 2014, at 2:04 AM, Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org> wr=
ote:
>> =

>>> =

>>> =

>>> [snip]
>>> =

>>> In relation to ports and datapaths it seems to me that the API that
>>> has been developed accommodates a model where a port may belong to a
>>> switch device; that this topology is fixed before any API calls are made
>>> and that all all ports belonging to the same switch belong to the same
>>> datapath.
>>> =

>>> This makes sense in the case of hardware that looks a lot like a switch.
>>> But I think that other scenarios are possible. For example hardware that
>>> is able to handle the same abstractions handled by the datapath: datapa=
ths
>>> may be created or destroyed; vports may be added and removed from datap=
aths.
>>> =

>>> So one might have a piece of hardware that is configured with more than=
 one
>>> datapath configured and its different ports belong to it might be
>>> associated with different data paths.
>> =

>> I=92ve tested multiple datapaths on one switch hardware with the current=
 patch set and it works fine, without the need to push down any datapath id=
 in the API.  It works because a switch port can=92t belong to more than on=
e datapath.  Datapaths can be created/destroyed and ports added/removed fro=
m datapaths dynamically and the right sw_flows are added/removed to program=
 HW.
> =

> And the flows added to a switch always match the in port? Thus
> so a given flow is only ever for one in-port and thus one datapath?

Correct, for the particular switch implementation we=92re working with.  If=
 another implementation can=92t match on in_port then it seems datapath_id =
may be needed to partition flows.  =



>>> Or we might have hardware that is able to offload a tunnel vport.
> =

> I think tunnel vports is still an unsolved part of the larger puzzle.

Agreed, TBD work to offload tunnel vports.  Current implementation only loo=
king at VLAN vports so far.

> =

>>> In short I am thinking in terms of API callbacks to manipulate datapaths
>>> and vports. Although I have not thought about it in detail I believe
>>> that the current model you have implemented using such a scheme because
>>> the scheme I am suggesting maps to that of the datapath and you have
>>> implemented your model there.


-scott
