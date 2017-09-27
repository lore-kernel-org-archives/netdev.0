From: Jiri Benc <jbenc@redhat.com>
Subject: Re: tc H/W offload issue with vxlan tunnels [was: nfp: flower vxlan
 tunnel offload]
Date: Wed, 27 Sep 2017 17:27:29 +0200
Message-ID: <20170927172729.5b7a8c44@griffin>
References: <1506500975.2867.19.camel@redhat.com>
        <20170927091700.GC1944@nanopsycho.orion>
        <1506505618.2867.34.camel@redhat.com>
        <20170927111150.GE1944@nanopsycho.orion>
        <1506515496.6840.6.camel@redhat.com>
        <20170927125509.GG1944@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Paolo Abeni <pabeni@redhat.com>, Or Gerlitz <gerlitz.or@gmail.com>,
        Simon Horman <simon.horman@netronome.com>,
        David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com, John Hurley <john.hurley@netronome.com>,
        Paul Blakey <paulb@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>, Roi Dayan <roid@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47954 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752028AbdI0P1e (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 27 Sep 2017 11:27:34 -0400
In-Reply-To: <20170927125509.GG1944@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 Sep 2017 14:55:09 +0200, Jiri Pirko wrote:
> So where do you attach the tc filter instead of eth0? vxlan0?

Yes, vxlan0. I'm pasting the example from earlier in this thread again:

This will match:

ip link add vxlan0 type vxlan dstport 4789 dev eth0 external
ip link set dev vxlan0 up
tc qdisc add dev vxlan0 ingress
ethtool -K eth0 hw-tc-offload on
tc filter add dev vxlan0 protocol ip parent ffff: flower enc_key_id 102 \
   enc_dst_port 4789 src_ip 3.4.5.6 skip_sw action [...]

while this must NOT match:

ip link add vxlan0 type vxlan dstport 4789 dev eth0 external
ip link set dev vxlan0 up
tc qdisc add dev eth0 ingress
ethtool -K eth0 hw-tc-offload on
tc filter add dev eth0 protocol ip parent ffff: flower enc_key_id 102 \
   enc_dst_port 4789 src_ip 3.4.5.6 skip_sw action [...]

 Jiri
