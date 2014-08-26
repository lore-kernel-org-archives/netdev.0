From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support
 for datapath hardware offload
Date: Tue, 26 Aug 2014 13:13:30 -0700
Message-ID: <CAADnVQLeNTQO9rekWRAb_2MWgiZqEiZ4p6GAsypdkhgg3xQffw@mail.gmail.com>
References: <20140825141754.GA30140@casper.infradead.org>
 <53FB6122.2040901@mojatatu.com>
 <20140825225057.GD30140@casper.infradead.org>
 <53FC909D.8090000@cumulusnetworks.com>
 <20140826140630.GA1848@nanopsycho.lan>
 <53FCA0AE.9010304@mojatatu.com>
 <20140826152217.GA1843@nanopsycho.lan>
 <53FCA7C6.5070804@mojatatu.com>
 <20140826154459.GB1843@nanopsycho.lan>
 <20140826155426.GA5275@gospo.rtplab.test>
 <20140826161956.GA15316@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org,
 Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andy Gospodarek <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>,
 "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org,
 Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 Andy Gospodarek <gospo-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
 Shrijeet Mukherjee <shm-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
 John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 ogerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org, buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org,
 Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>, Roopa Prabhu <roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
 Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>, dborkman <dborkman-H+wXaHxf7aJhl2p70BpVqQ@public.gmane.org
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20140826161956.GA15316-FZi0V3Vbi30CUdFEqe4BF2D2FQJk+8+b@public.gmane.org>
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

On Tue, Aug 26, 2014 at 9:19 AM, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org> wrote:
>
> Wait... I don't want to use OpenFlow to configure my laptop ;-)

+1

> We should leave the controller out of this discussion though. A
> controller is not required to run OVS at all. OpenStack Neutron
> is a very good example for that. There are even applications which
> use the OVS kernel datapath but not the OVS user space portion.
> We have a wide set of APIs serving different purposes and need to
> account for all of them. I'm as much interested in an offloaded
> nftables and tc command as you.

I think it's important distinction. In-kernel OVS is not OF.
It's a networking function that has hard-coded packet parser,
N-tuple match and programmable actions.
There were times when HW vendors were using OF check-box
to sell more chips, but at the end there is not a single HW
that is fully OF compliant. OF brand is still around, but
OF 2.0 is not tcam+action anymore.
Imo trying to standardize HW offload interface based on OF 1.x
principles is strange. Does anyone has performance data
that shows that hard-parser+N-tuple-match offload actually speeds
up real life applications ?
Why are we designing kernel offload based on 'rocker' emulator?
Enterprise silicon I've seen doesn't look like it...
I'm not saying that kernel should not have a driver for rocker.
It should, but it shouldn't be a golden model for HW offload.

"straw-man proposal for OF 2.0" paper have very
interesting ideas:
http://arxiv.org/pdf/1312.1719.pdf
sooner or later off the shelf NICs will have similar functionality.

In Linux we already have bridge that is perfect abstraction of
L2 network functions. OF 1.x has to use 'tcam' to do bridge and
in-kernel OVS has to fall back to 'mega-flows', but HW has proper
exact match tables and HW mac learning,
so OF 1.x principles just don't fit to L2 offloading.
