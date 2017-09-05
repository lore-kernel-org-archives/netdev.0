From: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH net-next v6 3/3] openvswitch: enable NSH
	support
Date: Tue, 05 Sep 2017 15:34:21 +0200
Message-ID: <874lshmfqa.fsf@stressinduktion.org>
References: <1503670805-31051-1-git-send-email-yi.y.yang@intel.com>
	<1503670805-31051-4-git-send-email-yi.y.yang@intel.com>
	<87wp5l7560.fsf@stressinduktion.org>
	<20170904023831.GA68062@cran64.bj.intel.com>
	<87mv6abte5.fsf@stressinduktion.org>
	<20170905021112.GA86057@cran64.bj.intel.com>
	<87vakxsaj2.fsf@stressinduktion.org>
	<CFF8EF42F1132E4CBE2BF0AB6C21C58D787F5650@ESESSMB107.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "e@erig.me" <e@erig.me>
To: Jan Scheurich <jan.scheurich-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CFF8EF42F1132E4CBE2BF0AB6C21C58D787F5650-hqolJogE5njKJFWPz4pdheaU1rCVNFv4@public.gmane.org>
	(Jan Scheurich's message of "Tue, 5 Sep 2017 12:19:11 +0000")
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

Hello Jan,

Jan Scheurich <jan.scheurich-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org> writes:

> Please have a look at the Google doc that sketches the overall
> solution to support NSH in OVS.
> https://drive.google.com/open?id=1oWMYUH8sjZJzWa72o2q9kU0N6pNE-rwZcLH3-kbbDR8
>
> In details it is slightly outdated but the NSH MD1 support (and all
> prerequisites like PTAP and Generic Encap/Decap) have been implemented
> in OVS 2.8 (ofproto layer and the userspace datapath).
>
> The NSH use cases are discussed in the chapter "Support for NSH". OVS
> is primarily targeting the Classifier and SFF use cases. Obviously the
> classifier must be able to set the MD1 context headers. The final SFF
> must be able to inspect the context headers, typically to determine
> the L2 or L3 forwarding context (e.g. VRF) in which to forward the
> decapsulated packet on to its final destination.

>From Yi Yang's mail I understood that you put a tunnel ID into
context[0]. In this case, I can understand that you want to match on
that. I was under the impression that the combination of tenant id from
the vxlan-gpe header and the path id plus ttl would give enough state
for the SDN to keep state on where the packet is in the network. I don't
understand what a tunnel id is.

I understood that the context fields are usable by the service function
chains, but they are actually in use by the outer SDN and basically
standardized.

> This information has end-to-end significance for the SFP and is
> encoded by the classifier in the NSH context headers. It cannot be put
> into transport tunnel options of e.g. a Geneve tunnel connecting two
> SFFs along the SFP.

Because the TLVs are not end to end in the geneve case? Yes, this makes
sense.

> We are now trying to establish feature parity in the kernel
> datapath. If the kernel datapath chooses not to support the MD1
> fields, OVS with kernel datapath will not be able to address the
> classifier and final SFF use cases.

As I understand this now, you are designing some kind of protocol or
particular implementation on top of NSH. Thus you don't expect masks to
grow limitless and you don't allow any SFC elements to take part in the
decision what to communicate over the context fields.

I still wonder about the hash as part of the NSH context and how that
fits into the picture, which looked like the only standardized
application of context headers from your google doc.

Btw., I don't want to block this patch.

Bye,
Hannes
