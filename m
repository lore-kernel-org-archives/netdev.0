From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: Fw: [Bug 196093] New: dot1q S-VLAN frame on dot1ad configured
 interface is accepted
Date: Mon, 19 Jun 2017 11:35:26 +0900
Message-ID: <23a32c50-a3e5-7b9e-43f1-04f835be2059@lab.ntt.co.jp>
References: <20170616084001.711f687c@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        jason-kernelbugzilla@lixfeld.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:56044 "EHLO
        tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753227AbdFSChA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Jun 2017 22:37:00 -0400
In-Reply-To: <20170616084001.711f687c@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 2017/06/17 0:40, Stephen Hemminger wrote:
> I suspect that VLAN offload on this Intel NIC is allowing any of the VLAN types.
> 
> Begin forwarded message:
> 
> Date: Fri, 16 Jun 2017 15:33:35 +0000
> From: bugzilla-daemon@bugzilla.kernel.org
> To: stephen@networkplumber.org
> Subject: [Bug 196093] New: dot1q S-VLAN frame on dot1ad configured interface is accepted
> 
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=196093
> 
>             Bug ID: 196093
>            Summary: dot1q S-VLAN frame on dot1ad configured interface is
>                     accepted
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 3.16.0 and 4.9.0
>           Hardware: Intel
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>           Assignee: stephen@networkplumber.org
>           Reporter: jason-kernelbugzilla@lixfeld.ca
>         Regression: No
> 
> Using the following configuration on an Intel 82599 port.  Tested in Debian 8
> with Kernel 3.16.0 and 4.9.0:
> 
> ip link set dev eth4 up
> ip link add link eth4 eth4.100ad type vlan proto 802.1ad id 100
> ip link add link eth4.100ad eth4.100ad.10q type vlan proto 802.1Q id 10
> ip link set dev eth4 netns nni-ad
> ip link set dev eth4.100ad netns nni-ad
> ip link set dev eth4.100ad.10q netns nni-ad
> ip netns exec nni-ad ip link set dev eth4 up
> ip netns exec nni-ad ip link set dev eth4.100ad up
> ip netns exec nni-ad ip link set dev eth4.100ad.10q up
> ip netns exec nni-ad ip addr add 10.4.100.10/8 dev eth4.100ad.10q
> 
> Ping to 10.4.100.10 while doing tcpdump on eth4 shows the frame has ether type
> 0x8100 (dot1q) on the S-VLAN, not 0x88a8 (dot1ad), yet the frame is still

libpcap was not reliable in vlan protocol parsing.
https://github.com/the-tcpdump-group/libpcap/pull/346
AFAIK libpcap 1.7.2 is required to parse it correctly.

> accepted, and an echo reply is generated.
> 
> The echo reply has the correct ethertype on the S-VLAN (0x88a8).  My
> understanding is that if the frame received on the wire does not match the
> ether type of the configured interface, the frame should be dropped?

Yes, it should.

Toshiaki Makita
