From: John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [patch net-next RFC 04/12] rtnl: expose physical
 switch id for particular device
Date: Fri, 22 Aug 2014 12:08:39 -0700
Message-ID: <53F79537.20207@gmail.com>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
 <1408637945-10390-5-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org,
 buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
 aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org,
 dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1408637945-10390-5-git-send-email-jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
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

On 08/21/2014 09:18 AM, Jiri Pirko wrote:
> The netdevice represents a port in a switch, it will expose
> IFLA_PHYS_SWITCH_ID value via rtnl. Two netdevices with the same value
> belong to one physical switch.
>
> Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>

What is the relation between phys_port_id and phys_switch_id?

phys_port_id was intended to identify a set of ports that belong
to a single uplink port,


	eth0     eth1    eth2   eth3      (host facing)
           |       |       |      |
           |       |       |      |
       +---+-------+-------+------+---+
       |      embedded switch         |
       +------------------------------+
                      |
                     MAC                   (network)

In the NIC case there is a simply switch with a port to the
network which we currently don't represent with a netdev. Any
netdev where the phys_switch_id's are behind the same embedded
switch.

In the switch id case we are indicating the port is attached to
the same embedded switch as well.

          eth0 eth1 eth2 eth3
           |    |    |    |
      +----+----+----+----+----+
      |         switch         |
      +----+----+----+----+----+

but they do not share an uplink port? So in this case each ethx
has a unique phys_port_id but the same phys_switch_id?

In the first case both phys_port_id and phys_switch_id should
be equal for all interfaces correct?

Is that clear/useful at all? We need to document this somewhere
if/when the patches are submitted otherwise I doubt we will get it
consistently right across drivers. There could for example be
somewhat strange devices with virtual functions hanging off of the
switch.

Thanks,
John

-- 
John Fastabend         Intel Corporation
