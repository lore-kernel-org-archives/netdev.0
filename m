From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: Re: [patch net-next RFC v2 0/6] introduce infrastructure
 for support of switch chip datapath
Date: Thu, 27 Mar 2014 18:26:00 +0100
Message-ID: <20140327172600.GP2845@minipsycho.orion>
References: <1395851472-10524-1-git-send-email-jiri@resnulli.us>
 <53334A3F.6020105@mojatatu.com>
 <20140327072107.GC2845@minipsycho.orion>
 <5333FD12.9060404@mojatatu.com>
 <20140327110223.GA1615@casper.infradead.org>
 <CAGVrzcYE9uuD0Gxd5-OND4p5ieikYFchhpBm=ZiK5GaMqiQVyA@mail.gmail.com>
 <20140327172048.GC13573@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andy Gospodarek <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>,
 dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ogerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
 Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>, Roopa Prabhu <roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
 Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
 vyasevic <vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
 Scott Feldman <sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>, dborkman <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140327172048.GC13573-FZi0V3Vbi30CUdFEqe4BF2D2FQJk+8+b@public.gmane.org>
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

Thu, Mar 27, 2014 at 06:20:48PM CET, tgraf-G/eBtMaohhA@public.gmane.org wrote:
>On 03/27/14 at 09:27am, Florian Fainelli wrote:
>> 2014-03-27 4:02 GMT-07:00 Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>:
>> > There is definitely need beyond an ndo that is capable of
>> > adding flows. You mention routes. Another example would be
>> > devices capable of offloading iptables & nft rules.
>> 
>> Those devices usually require (at least for Broadcom) an entity
>> identifying the flows and uploading flows offloading rules to the
>> hardware. Although I do not think it hurts to keep those in mind to
>> come up with the right design, my feeling is that they will require
>> more intrusive modifications at the socket, route and forwarding path
>> level if we want the Linux kernel to offer a consistent API across
>> different hardware variations.
>
>I absolutely agree. This is where the challenging bits start to
>appear ;-) I don't want to speak for Jiri but my understanding is
>that the flow focused approach early on is entirely because it is
>the easiest case to solve. Taking OVS as an example has the
>advantage of already being guarded by OpenFlow abstraction which
>by nature is very device oriented.

Yep, exactly.

>
>> It is not clear to me at this point whether we want those special
>> offloading devices to appear as separate net_device with specific
>> flags to advertise their offloading features (NAT, IP routing...) or
>> something else?
>
>One lesson that could serve as an example which differs from TOE is
>the offloading provided by recent FC HBAs. The device looks like a
>regular SCSI device to the kernel but offers a full DCB engine to
>allow for FCoE. The DCB bits can and must be configured. By not
>representing that engine with a net_device we cannot configure the
>engine through the Netlink interface dcbnl. dcbnl can certainly be
>extended to allow taking a scsi id of some sort instead of a ifindex
>but it's far from ideal.
>
>My take on this is that if it makes sense to use rtnl or ethtool
>to configure these offload engines then let's just go with a
>globally visible net_device and improve our capabilities system.
>
>> > But wouldn't you want to introduce an additional ndo to
>> > cover these?
>> 
>> I would start with making sure everyone is on the same page regarding
>> switches before we start building the conversation on NAT/IP-routing
>> offloading, but it is good that you mention it.
>
>Agreed
