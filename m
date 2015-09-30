From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [ovs-dev] [PATCH net-next 1/2] openvswitch: add tunnel protocol
 to sw_flow_key
Date: Wed, 30 Sep 2015 22:52:49 +0200
Message-ID: <20150930225250.3192e5a7@griffin>
References: <cover.1443548447.git.jbenc@redhat.com>
	<428cee4cb7e04cfea5bef90b37d257562ea78a83.1443548447.git.jbenc@redhat.com>
	<CALnjE+qWmENWj_hL87++Sk=zzrvj2U0VAEW26ySAjg5RsDymuA@mail.gmail.com>
	<20150930090946.4e4bb610@griffin>
	<CALnjE+pNXwAisxyZnb3Lik1ZMa_0QLvLip9TOOqLEZUbboT8BQ@mail.gmail.com>
	<CAEP_g=--y7J36S7fKVUA2Hjb=Sy=iRHot2XsJ=RbNTM20HhA1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Pravin Shelar <pshelar@nicira.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33523 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932747AbbI3Uwy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 16:52:54 -0400
In-Reply-To: <CAEP_g=--y7J36S7fKVUA2Hjb=Sy=iRHot2XsJ=RbNTM20HhA1A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Sep 2015 13:25:12 -0700, Jesse Gross wrote:
> On Wed, Sep 30, 2015 at 1:13 PM, Pravin Shelar <pshelar@nicira.com> wrote:
> > On Wed, Sep 30, 2015 at 12:09 AM, Jiri Benc <jbenc@redhat.com> wrote:
> >> On Tue, 29 Sep 2015 13:41:34 -0700, Pravin Shelar wrote:
> >>> We can add rather add TUNNEL_IPV6 flag to distinguish IPv4 and IPv6
> >>> tunnel keys. This can be stored in ip_tunnel_key.tun_flags.
> >>
> >> Not really. This was my original approach, too, but openvswitch is not
> >> the only user of struct ip_tunnel_key, and in the lwtunnel core,
> >> tun_flags are handled in the way that makes this impractical. Most
> >> importantly, the tun_flags value is directly taken from/stored to
> >> LWTUNNEL_IP_FLAGS/LWTUNNEL_IP6_FLAGS netlink attributes in
> >> net/ipv4/ip_tunnel_core.c. This would mean complicated masking, etc.
> >>
> > How is it impractical ? Userspace can set flag for IPv6 tunnel info.
> > That should be easy.
> >
> > IPv6 bit can not be masked anyways so I do not see problem with
> > masking this flag due to the new bit.
> 
> I think he meant for non-OVS users.

Yes, I didn't mean masking in ovs, I meant that we'd need to hide the
bit from other users, for example in net/ipv4/ip_tunnel_core.c.
Currently, the information about ip_tunnel_key protocol is stored
outside the structure. Changing this would mean quite big changes in
the lwtunnel code (or, rather, IP users of lwtunnel) which doesn't seem
worth it just because of ovs. Especially when ovs can store the
information just fine without impact on memory footprint.

I don't see any real advantage in storing the protocol inside
ip_tunnel_key, this looks like it would be just a change for the change.

> > Since this field is exposed to userspace. TUNNEL_* flags needs to be
> > moved to uapi header.
> 
> This doesn't really seem all that desirable to me. It's nice to be
> able to change these as necessary and in the particular case of IPv6,
> it seems like something that the kernel can manage by itself (as is
> done in this patch and I think the same strategy would apply
> regardless of the particular representation).

User space can set and get those bits in LWTUNNEL_IP_FLAGS netlink
attribute when using lwtunnel+routing rules. It would make sense to
move them to uapi but that's for a different patch(set).

 Jiri

-- 
Jiri Benc
