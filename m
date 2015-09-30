From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 2/2] openvswitch: netlink attributes for IPv6
 tunneling
Date: Wed, 30 Sep 2015 09:28:50 +0200
Message-ID: <20150930092850.09b71dff@griffin>
References: <cover.1443548447.git.jbenc@redhat.com>
	<ac7ce77d8104dca2c8378096575276984dd2a11e.1443548447.git.jbenc@redhat.com>
	<CAEP_g=-oijtUY1fD7AqK5PndCAt85uEF1Gh0yqbqz0u3-bPcRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Pravin Shelar <pshelar@nicira.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50963 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753752AbbI3H2y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 03:28:54 -0400
In-Reply-To: <CAEP_g=-oijtUY1fD7AqK5PndCAt85uEF1Gh0yqbqz0u3-bPcRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Sep 2015 20:05:00 -0700, Jesse Gross wrote:
> This appears to me to be a bug in the existing code.
> ovs_tunnel_get_egress_info() as a general mechanism is still in use
> and should work with both the old and new configuration methods.

It's currently used only from the compat layer (the API that the user
space that is unaware of lwtunnels use).

I don't understand what it would be good for with lwtunnel based
tunnels. The metadata_dst is created in the validate_and_copy_set_tun
function (net/openvswitch/flow_netlink.c) and used to specify egress
encapsulation metadata. The ovs_tunnel_get_egress_info function is not
needed.

> However, I agree that it doesn't look like it will work currently with
> tunnel devices. I think we need to fix this rather than making it more
> broken.

I'm not making it more broken. We currently (i.e. right now, in the
current net.git) have two APIs for tunnel specification in the ovs
kernel datapath: the old one, which is translated by the compat layer
to create a net_device, and the lwtunnel one, which requires user space
to create a (metadata) tunnel net_device and add it to the datapath.
I'm simply not adding more code to the first, legacy interface, which
seems to be the correct thing to do.

 Jiri

-- 
Jiri Benc
