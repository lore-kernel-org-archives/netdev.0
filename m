From: Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch net-next RFC 03/12] net: introduce generic
	switch devices support
Date: Tue, 26 Aug 2014 19:45:44 -0700
Message-ID: <CA+mtBx8qWTUbqJ1QFKzqkQEuXdvvrtkQDC8r=y-d_2zr=7uQ1Q@mail.gmail.com>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
 <1408637945-10390-4-git-send-email-jiri@resnulli.us>
 <1408639283.13073.3.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Jason Wang <jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org,
 Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
 Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>,
 Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
 Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
 Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
 Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1408639283.13073.3.camel-nDn/Rdv9kqW9Jme8/bJn5UCKIB8iOfG2tUK59QYPAWc@public.gmane.org>
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

On Thu, Aug 21, 2014 at 9:41 AM, Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org> wrote:
> On Thu, 2014-08-21 at 18:18 +0200, Jiri Pirko wrote:
>> The goal of this is to provide a possibility to suport various switch
>> chips. Drivers should implement relevant ndos to do so. Now there is a
>> couple of ndos defines:
>> - for getting physical switch id is in place.
>> - for work with flows.
>>
>> Note that user can use random port netdevice to access the switch.
> [...]
>
> Why isn't the switch treated as a real device (not necessarily a net
> device) that's included in the device model and that the port devices
> refer to?
>
+1. In the same way that software switch (e.g. OVS) is mostly
implemented out of the core stack, I think hardware switch should have
same model. Besides, if you define this as part of a network interface
then you'll need to resolve unpleasant issues like accounting for
bytes and packets switched (e.g. are these accounted in interface
stats?)), what happens if netdevice is put in promiscuous mode (e.g.
do we need a tap for all switched packets?), etc. Another thing to
consider is that some vendors will undoubtably implement an open flow
agent in the NIC to manage the switch, possibly even autonomously from
the host-- a host might see the device but not be able to manage it
other than adding interfaces as local ports.

> Ben.
>
> --
> Ben Hutchings
> If at first you don't succeed, you're doing about average.
