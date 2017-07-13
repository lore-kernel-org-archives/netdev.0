From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH net-next v1 0/3] Flow Based GTP Tunneling
Date: Thu, 13 Jul 2017 09:12:49 +0200
Message-ID: <20170713071249.lk7dph6bpzgn622d@nataraja>
References: <20170713004455.3946570-1-ouyangj@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: osmocom-net-gprs@lists.osmocom.org, netdev@vger.kernel.org,
        dev@openvswitch.org, pablo@netfilter.org, pshelar@nicira.com,
        wieger.ijntema.tno@gmail.com, yi.y.yang@intel.com, joe@ovn.org,
        amarpadmanabhan@fb.com
To: Jiannan Ouyang <ouyangj@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [213.95.27.120] ([213.95.27.120]:38685 "EHLO
        ganesha.gnumonks.org" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
        with ESMTP id S1750954AbdGMHPl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 03:15:41 -0400
Content-Disposition: inline
In-Reply-To: <20170713004455.3946570-1-ouyangj@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi Jiannan,

net-next si closed, as it has been pointed out already by Joe.

On Wed, Jul 12, 2017 at 05:44:52PM -0700, Jiannan Ouyang wrote:
> ovs-ofctl add-flow br0
>     "in_port=2,tun_src=192.168.60.141,tun_id=123, \
>     actions=set_field:02:00:00:00:00:00->eth_src, \
>     set_field:ff:ff:ff:ff:ff:ff->eth_dst,LOCAL"

I'm not familiar with the details here, but does this imply that you
are matching on the outer (transport layer) source IP address? If so,
please note this is in violation of the 3GPP specifications for GTP,
which require explicitly that the TEID is the *only* criteria for
matching an encapsulated packet to the tunnel.  Basically anyone can
send you an encapsulated packet from any random source IP, just as long
as the TEID matches a tunnel, it will be decapsulated.

This is [presumably] in order to take care of mobility, as the
subscribers' phone moves around different MME/S-GW/SGSN, each having
different source IP addresses.

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
