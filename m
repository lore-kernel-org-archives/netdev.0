From: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Subject: Re: [patch net-next RFC 03/12] net: introduce generic
 switch devices support
Date: Fri, 22 Aug 2014 08:42:04 -0400
Message-ID: <53F73A9C.4000209@mojatatu.com>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
 <1408637945-10390-4-git-send-email-jiri@resnulli.us>
 <CAGVrzcYtnpcP4pfCJ0GSya01LTk0WwbSV1f+voF2K=S5CR3Arg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Sergey Ryazanov <ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 "jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 Neil Jerram <Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
 Andy Gospodarek <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>, dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>, ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, ogerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
 Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
 Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>,
 Roopa Prabhu <roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>, Aviad Raveh <aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
 Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>, vyasevic <vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>, dborkman <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAGVrzcYtnpcP4pfCJ0GSya01LTk0WwbSV1f+voF2K=S5CR3Arg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On 08/21/14 13:05, Florian Fainelli wrote:
> 2014-08-21 9:18 GMT-07:00 Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>:
>> The goal of this is to provide a possibility to suport various switch
>> chips. Drivers should implement relevant ndos to do so. Now there is a
>> couple of ndos defines:
>> - for getting physical switch id is in place.
>> - for work with flows.
>>
>> Note that user can use random port netdevice to access the switch.
>
> I read through this patch set, and I still think that DSA is the
> generic switch infrastructure we already have because it does provide
> the following:
>
> - taking a generic platform data structure (C struct or Device Tree),
> validate, parse it and map it to internal kernel structures
> - instantiate per-port network devices based on the configuration data provided
> - delegate netdev_ops to the switch driver and/or the CPU NIC when relevant
> - provide support for hooking RX and TX traffic coming from the CPU NIC
>
> I would rather we build on the existing DSA infrastructure and add the
> flow-related netdev_ops rather than having the two remain in
> disconnect while flow-oriented switches driver get progressively
> added. I guess I should take a closer look at the rocker driver to see
> how hard would that be for you.
>
> What do you think?


I thought we had concluded that DSA was a good path forward?  Or maybe 
at this stage we need to have several alternative approaches
and we eventually converge?

cheers,
jamal
