From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/22 v2] Lightweight & flow based
 encapsulation
Date: Tue, 21 Jul 2015 10:39:44 -0700 (PDT)
Message-ID: <20150721.103944.1416365175440789268.davem@davemloft.net>
References: <cover.1437468140.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, daniel@iogearbox.net,
	tom@herbertland.com, edumazet@google.com, jiri@resnulli.us,
	marcelo.leitner@gmail.com, stephen@networkplumber.org,
	jpettit@nicira.com, kaber@trash.net, simon.horman@netronome.com,
	joestringer@nicira.com, ja@ssi.bg, ast@plumgrid.com,
	weichunc@plumgrid.com, netdev@vger.kernel.org, dev@openvswitch.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60428 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755728AbbGURjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 13:39:46 -0400
In-Reply-To: <cover.1437468140.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 21 Jul 2015 10:43:44 +0200

> This series combines the work previously posted by Roopa, Robert and
> myself. It's according to what we discussed at NFWS. The motivation
> of this series is to:
> 
>  * Consolidate code between OVS and the rest of the kernel and get
>    rid of OVS vports and instead represent them as pure net_devices.
>  * Introduce a lightweight tunneling mechanism which enables flow
>    based encapsulation to improve scalability on both RX and TX.
>  * Do the above in an encapsulation unspecific way so that the
>    encapsulation type is eventually abstracted away from the user.
>  * Use the same forwarding decision for both native forwarding and
>    encapsulation thus allowing to switch between native IPv6 and
>    UDP encapsulation based on endpoint without requiring additional
>    logic
> 
> The fundamental changes introduces in this series are:
>  * A new RTA_ENCAP Netlink attribute for routes carrying encapsulation
>    instructions. Depending on the specified type, the instructions
>    apply to UDP encapsulations, MPLS and possible other in the future.
>  * Depending on the encapsulation type, the output function of the
>    dst is directly overwritten or the dst merely attaches metadata and
>    relies on a subsequent net_device to apply it to the packet. The
>    latter is typically used if an inner and outer IP header exist which
>    require two subsequent routing lookups to be performed.
>  * A new metadata_dst structure which can be attached to skbs to
>    carry metadata in between subsystems. This new metadata transport
>    is used to provide a single interface for VXLAN, routing and OVS
>    to communicate through metadata.

Series applied, but please take Alexei's endianness feedback into
consideration.

Thanks!
