From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: dummy as IMQ replacement
Date: Mon, 31 Jan 2005 16:14:31 +0200
Message-ID: <200501311614.31397.hasso@estpak.ee>
References: <1107123123.8021.80.camel@jzny.localdomain> <200501311502.56796.hasso@estpak.ee> <1107178770.7840.151.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1107178770.7840.151.camel@jzny.localdomain>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Mon, 2005-01-31 at 08:02, Hasso Tepper wrote:
> > All traffic coming from eth1.101 interface.
>
> eth1.101 is an alias? You may have issues there. Maybe not if the
> attach to that interface worked.

No, vlan.

> Theres other ways to do it[1] but if theres a bug in this it needs
> fixing.
>
> cheers,
> jamal
>
> [1]
> Example, you could do this:
>
> tc filter add dev eth1 parent ffff: protocol ip prio 1 \
> u32 match u32 0 0 flowid 1:15 \
> action police index 1 rate 1024kbit burst 60k drop index 1
>
> Note the use of "index 1" to select a policer.
>
> Then repeat replacing ip with ip6; make sure that "index 1" for policer
> stays. You could do this to share also across devices.
>
> Example, on egress of eth0 also use the same 1Mbps
>
> tc filter add dev eth0 parent 1:0 protocol ip prio 6 u32 \
> match ip src 10.0.0.21/32 flowid 1:16 \
> action police index 1 rate 1024kbit burst 60k drop index 1
>
> Now with new action stuff you could instead just have said:
> tc actions add \
> action police index 1 rate 1024kbit burst 60k drop index 1
>
> And then later just referenced it without having to repeat the rate
> like so:
> filter add dev eth0 parent ffff: protocol ip prio 6 u32 match ip src \
> 10.0.0.21/32 flowid 1:16 \
> action police index 1

Hmmm ... I even didn't know about index. Yes, something like that would do 
as well probably. I'll do some tests later today with this. Actions don't 
help me though as I'm using 2.4 kernel for production.


-- 
Hasso Tepper
Elion Enterprises Ltd.
WAN administrator
