From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: e1000 problem with NAPI?
Date: Tue, 1 Mar 2005 14:59:31 +0100
Message-ID: <20050301135931.GA14610@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, robert.olsson@data.slu.se
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all,

I'm seeing some strange issues with an e1000 NIC.  I'm flooding it
with tinygrams from a packet generator and then abruptly stop the
generator.  The last few packets from the burst don't come through
until after two seconds.  Sometimes there are multiple trailing
bursts, each of them separated by two seconds.

For example:  (The low 24 bits of the destination address are set
to the packet sequence number by the generator.)

14:44:19.649874 IP 10.10.0.0 > 1.4.10.11: [|tcp]
14:44:19.649878 IP 10.10.0.0 > 1.4.10.12: [|tcp]
14:44:19.649882 IP 10.10.0.0 > 1.4.10.13: [|tcp]
14:44:19.649887 IP 10.10.0.0 > 1.4.10.14: [|tcp]
14:44:19.649891 IP 10.10.0.0 > 1.4.10.15: [|tcp]
14:44:19.649895 IP 10.10.0.0 > 1.4.10.16: [|tcp]
14:44:19.649899 IP 10.10.0.0 > 1.4.10.17: [|tcp]
14:44:21.650293 IP 10.10.0.0 > 1.4.10.18: [|tcp]		<=== delayed
14:44:21.650303 IP 10.10.0.0 > 1.4.10.19: [|tcp]
14:44:21.650308 IP 10.10.0.0 > 1.4.10.20: [|tcp]
14:44:21.650312 IP 10.10.0.0 > 1.4.10.21: [|tcp]
14:44:21.650316 IP 10.10.0.0 > 1.4.10.22: [|tcp]
14:44:21.650320 IP 10.10.0.0 > 1.4.10.23: [|tcp]
14:44:21.650324 IP 10.10.0.0 > 1.4.10.24: [|tcp]
14:44:21.650328 IP 10.10.0.0 > 1.4.10.25: [|tcp]
14:44:21.650332 IP 10.10.0.0 > 1.4.10.26: [|tcp]

I wrote the packet generator code myself (ixp2400 platform), but I've
verified that the packets do leave the generator back-to-back.  What's
also strange is that when these trailing bursts come in, the interface
statistics counters do not change -- the packets in the trailing bursts
have already been counted by the time they show up in tcpdump.

Jamal suspects a NAPI 'rotting packet' issue, which doesn't sound all
that unlikely.  (Oh, this is kernel 2.6.10-something with e1000 driver
version "5.5.4-k2-NAPI".)

Ideas?


cheers,
Lennert
