From: Tim Gardner <timg@tpi.com>
Subject: Re: [PATCH} ARP auto-sizing for 2.4.24 - 2.4.26-pre3
Date: Tue, 16 Mar 2004 09:05:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403160905.01804.timg@tpi.com>
References: <200403141210.57266.timg@tpi.com> <20040315134412.314b5e23.davem@redhat.com>
Reply-To: timg@tpi.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: anton@samba.org, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040315134412.314b5e23.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Monday 15 March 2004 14:44, David S. Miller wrote:

> Your original email was nice in describing the fact that ARP does not
> scale, but you've made no foundation on which to erect a claim that
> scalability for ARP (and thus the added complexity/changes) is even
> necessary.

You are absolutely correct that ARP search performance is not an issue. I 
negelected to notice the 'struct dst_entry' mechanism built into sockets and 
route table entries. I assumed arp_find() was called for every outbound 
packet. Live and learn.

Given that ARP search times make no discernible difference (except when 
base_reachable_time is ridiculously low), why not remove the hash complexity 
altogether?

The issue that is driving me is that when I set base_reachable_time to a large 
value (approx 10 hrs) in order to cut down on ARP traffic in our large, 
bridged network, our 2.4.24 core router occaisionally fails to respond to a 
ping from only one address for an extended period. It also refuses to route 
that address. All other addresses appear to work. If I flush the host address 
in question on the core router using 'ip neigh flush', then everybody is fat, 
dumb, and happy. Hence my suspicions regarding ARP. This would be much easier 
if I could reliably reproduce the problem, but it is devilishly infrequent.

rtg
-- 
Tim Gardner - timg@tpi.com
www.tpi.com 406-443-5357
