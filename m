From: Jan Scheurich <jan.scheurich-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next v6 3/3] openvswitch: enable
	NSH	support
Date: Fri, 1 Sep 2017 12:11:03 +0000
Message-ID: <CFF8EF42F1132E4CBE2BF0AB6C21C58D787F33C4@ESESSMB107.ericsson.se>
References: <1503670805-31051-1-git-send-email-yi.y.yang@intel.com>
	<1503670805-31051-4-git-send-email-yi.y.yang@intel.com>
	<87wp5l7560.fsf@stressinduktion.org>
	<4B1BB321037C0849AAE171801564DFA6888FAED3@IRSMSX107.ger.corp.intel.com>
	<87inh56q8u.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"e@erig.me" <e@erig.me>, "jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>, "Mooney, Sean K"
	<sean.k.mooney-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
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

> > [Mooney, Sean K]
> > Having the nsh context headers in the flow is quite useful It would
> > allow loadblancing on values stored in the context headers Or other
> > use. I belive odl previously used context header 4 to store a Flow id
> > so this could potentialy be used with the multipath action to have ovs
> > Choose between several possible next hops in the chain.
> 
> In OVS, masks are a list(!) for matching. How can this work for different
> paths that might require different masks? If they can't be unified you even
> get exact matches. Thus, for OVS the context should not be part of the
> flow.

The NSH support in OVS 2.8 (for the user-space datapath only, so far) supports matching on and manipulating the fixed size MD1 context headers C1-C4. They are part of the flow and there are corresponding OXM fields defined. It is up to the SDN controller to program pipelines that match on or set these fields. 

The goal was to support all relevant NSH use cases for MD1: Classifier, SFF, and (with certain limitations) NSH proxy, and SF.

We also support MD2 TLV context headers but not yet for matching and setting, so MD2 TLVs are not part of the flow. OVS 2.8 can add MD2 context TLVs with the encap(nsh) action (classifier use case), can transparently forward MD2 headers (SFF use case) and pop an NSH header with MD2 context (final SFF use case). Support for matching and setting MD2 TLVs is FFS and can be added in a later release.

BR, Jan
