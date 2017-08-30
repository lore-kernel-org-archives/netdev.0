From: "Mooney, Sean K" <sean.k.mooney-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v6 3/3] openvswitch: enable NSH
 support
Date: Wed, 30 Aug 2017 19:00:44 +0000
Message-ID: <4B1BB321037C0849AAE171801564DFA6888FB254@IRSMSX107.ger.corp.intel.com>
References: <1503670805-31051-1-git-send-email-yi.y.yang@intel.com>
	<1503670805-31051-4-git-send-email-yi.y.yang@intel.com>
	<87wp5l7560.fsf@stressinduktion.org>
	<4B1BB321037C0849AAE171801564DFA6888FAED3@IRSMSX107.ger.corp.intel.com>
	<87inh56q8u.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "e@erig.me" <e@erig.me>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <87inh56q8u.fsf-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Hannes Frederic Sowa [mailto:hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org]
> Sent: Wednesday, August 30, 2017 4:16 PM
> To: Mooney, Sean K <sean.k.mooney-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Cc: Yang, Yi Y <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org;
> netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org; e@erig.me
> Subject: Re: [ovs-dev] [PATCH net-next v6 3/3] openvswitch: enable NSH
> support
> 
> "Mooney, Sean K" <sean.k.mooney-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> writes:
> 
> >> -----Original Message-----
> >> From: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org [mailto:ovs-dev-
> >> bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org] On Behalf Of Hannes Frederic Sowa
> >> Sent: Wednesday, August 30, 2017 10:53 AM
> >> To: Yang, Yi Y <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> >> Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org;
> >> e@erig.me
> >> Subject: Re: [ovs-dev] [PATCH net-next v6 3/3] openvswitch: enable
> >> NSH support
> >>
> >> Hello,
> >>
> >> Yi Yang <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> writes:
> >>
> >> [...]
> >>
> >> > +struct ovs_key_nsh {
> >> > +	u8 flags;
> >> > +	u8 ttl;
> >> > +	u8 mdtype;
> >> > +	u8 np;
> >> > +	__be32 path_hdr;
> >> > +	__be32 context[NSH_MD1_CONTEXT_SIZE]; };
> >> > +
> >> >  struct sw_flow_key {
> >> >  	u8 tun_opts[IP_TUNNEL_OPTS_MAX];
> >> >  	u8 tun_opts_len;
> >> > @@ -144,6 +154,7 @@ struct sw_flow_key {
> >> >  			};
> >> >  		} ipv6;
> >> >  	};
> >> > +	struct ovs_key_nsh nsh;         /* network service header */
> >> >  	struct {
> >> >  		/* Connection tracking fields not packed above. */
> >> >  		struct {
> >>
> >> Does it makes sense to keep the context headers as part of the flow?
> >> What is the reasoning behind it? With mdtype 2 headers this might
> >> either not work very well or will increase sw_flow_key size causing
> >> slowdowns for all protocols.
> > [Mooney, Sean K]
> > Having the nsh context headers in the flow is quite useful It would
> > allow loadblancing on values stored in the context headers Or other
> > use. I belive odl previously used context header 4 to store a Flow id
> > so this could potentialy be used with the multipath action to have
> ovs
> > Choose between several possible next hops in the chain.
> 
> In OVS, masks are a list(!) for matching. How can this work for
> different paths that might require different masks? If they can't be
> unified you even get exact matches. Thus, for OVS the context should
> not be part of the flow.
[Mooney, Sean K] I'm not sure what you mean about a list as I never made reference to one.
md type 1 context headers are 4 mandatory 32 bit field.
form an ovs context they should be treated the same as the 32 bit register fields.
We do not need to necessarily support those in md type 2 as all metadata is optional.
> 
> > Another example of where this is usefull is branching chains.  if I
> > assume that both the classifier and Service function forwarder are
> > collocated in ovs on the host, and is send A packet to a firewall
> > service function which tags the packet as suspicious Via setting a
> > context header metadata field to 1, I as the sdn controller can
> > Install a high priority rule that will reclassify the packet as part
> > of as separate Service function chain the will prefer dpi on the
> > packet before returning it to The original chain if demand not a
> > threat.
> 
> You can do that with different path id's, too?
[Mooney, Sean K] a service function is not allowed to alter the spi.
Only a classifier can do that. You are correct that a different spi is required for the branch
To the dpi sf but packets that are not droped can rejoin the original spi.
Packet are not require you to enter a service chain at the first hop.

service function chain are explicitly not A list. They are a directed graph composed
of service function instance or service function groups that generally 
are reducible to a directed acrylic graph and in the simple case to a simple list. 
branching an recovering chains are expected, as is loadblancing between 
service function instances in the same service function group which share the same spi. 
The spi filed in the nsh heard is intended to transport the logical service plane path id
not the rendered service path id.
> 
> > So while a sff dose not in general have to be able to match on the
> > context header If I assume I want to use ovs to implenet a classifier
> > or service function(e.g. loadblancer) The its desirable to be able to
> > both match on the context headers in md type1 and also be able To set
> > them(this is something classifies and service fuction are allowed to
> > do).
> 
> I don't think it is practical at all?
[Mooney, Sean K] To day in OpenStack we co-locate the clarifier at every
Ovs instance and use mpls as a standing for nsh doing proxing at every hop before sending
To an sf. Flow based load balancing is not only practical but has been demonstrated to work with odl gbp classifier
and sfc application controlling a patched ovs with nsh support in 2015. 

If you look at slide 36 of http://events.linuxfoundation.org/sites/events/files/slides/odl%20summit%20sfc%20v5.pdf
you will see that prior to the berilium release of odl context header 1 and 2 are used to allow multi-tenancy
and overlapping ips. For the loadblancing implentaiton I belived they also used context header 4 to store a flow id.
This require odl to generate openflow rules to set the context headers as part of classification.

You can also see that context header 1 and 2 are still used in the newer odl netvirt sfc classifier implementation
https://github.com/opendaylight/netvirt/blob/ba22f7cf19d8a827d77a3391a7f654344ade43d8/docs/specs/new-sfc-classifier.rst#pipeline-changes
so for odl existing nsh support to work with md type one we must have the ability to set the nsh context headers
and should have the ability to match on them also for load lancing between service function in service function group.
