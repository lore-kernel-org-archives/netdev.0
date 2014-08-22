From: Scott Feldman <sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Subject: Re: [patch net-next RFC 03/12] net: introduce generic
	switch devices support
Date: Fri, 22 Aug 2014 16:12:27 -0700
Message-ID: <7BD4F14A-193B-49D9-817F-E4E3B72F5FF1@cumulusnetworks.com>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
 <1408637945-10390-4-git-send-email-jiri@resnulli.us>
 <CAGVrzcYtnpcP4pfCJ0GSya01LTk0WwbSV1f+voF2K=S5CR3Arg@mail.gmail.com>
 <53F73A9C.4000209@mojatatu.com> <20140822125655.GB1916@nanopsycho.orion>
 <53F7969C.1060509@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: Sergey Ryazanov <ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 "jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 Neil Jerram <Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
 Andy Gospodarek <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>, dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 ogerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
 Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>, Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
 Roopa Prabhu <roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
 Aviad Raveh <aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>,
 vyasevic <vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>, dborkman <dbork
To: John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <53F7969C.1060509-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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


On Aug 22, 2014, at 12:14 PM, John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wro=
te:

> On 08/22/2014 05:56 AM, Jiri Pirko wrote:
>> Fri, Aug 22, 2014 at 02:42:04PM CEST, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org wrote:
>>> On 08/21/14 13:05, Florian Fainelli wrote:
>>>> 2014-08-21 9:18 GMT-07:00 Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>:
>>>>> The goal of this is to provide a possibility to suport various switch
>>>>> chips. Drivers should implement relevant ndos to do so. Now there is a
>>>>> couple of ndos defines:
>>>>> - for getting physical switch id is in place.
>>>>> - for work with flows.
>>>>> =

>>>>> Note that user can use random port netdevice to access the switch.
>>>> =

>>>> I read through this patch set, and I still think that DSA is the
>>>> generic switch infrastructure we already have because it does provide
>>>> the following:
>>>> =

>>>> - taking a generic platform data structure (C struct or Device Tree),
>>>> validate, parse it and map it to internal kernel structures
>>>> - instantiate per-port network devices based on the configuration data=
 provided
>>>> - delegate netdev_ops to the switch driver and/or the CPU NIC when rel=
evant
>>>> - provide support for hooking RX and TX traffic coming from the CPU NIC
>>>> =

>>>> I would rather we build on the existing DSA infrastructure and add the
>>>> flow-related netdev_ops rather than having the two remain in
>>>> disconnect while flow-oriented switches driver get progressively
>>>> added. I guess I should take a closer look at the rocker driver to see
>>>> how hard would that be for you.
>>>> =

>>>> What do you think?
>>> =

>>> =

>>> I thought we had concluded that DSA was a good path forward?  Or maybe =
at
>>> this stage we need to have several alternative approaches
>>> and we eventually converge?
>> =

>> That is true. I'm still unsure how to fit this on to DSA or how to chang=
e DSA
>> the way this fits. This is my quest now. Will report back in a week or s=
o.
>> =

> =

> I would like to use the flow ops in some of our NICs that have
> a limited flow table in hardware. It might be easier to use the
> NICs as the first implementers of the API even though they are
> usually not as capable or large as flow tables in some of the
> larger switch asics.
> =

> In my opinion it can replace the ioctl flow director APIs although
> I don't like how it is tied to OVS in the some of the later RFC patches
> but we can work on that.

I think parallel efforts to get flow ops working on a real NIC with limited=
 capabilities as well our fake enterprise-class rocker switch with full cap=
abilities will really help solidify the swdev API.  Maybe even someone in t=
he background that has access to a real enterprise switch can play along ;)=
.  I hope you=92re convinced from my other reply that the intent of swdev i=
s to be independent of OVS.  If the implementation in the RFC doesn=92t mat=
ch the intent, we should fix it.  The elements of the swdev API we need con=
vergence on are:

	- ndo_swdev_* ops to identify switch port and add/del flow match/action
	- struct sw_flow as generic flow match/action description
	- port netdevs to represent physical device ports

And maybe:

	- new device class to represent the switch itself
	- capabilities to express HW capabilities (limits, constraints, etc)


-scott
