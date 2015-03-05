From: Guy Harris <guy@alum.mit.edu>
Subject: Re: [PATCH] filter: introduce SKF_AD_VLAN_PROTO BPF extension
Date: Thu, 5 Mar 2015 00:35:01 -0800
Message-ID: <96C60242-C380-4B97-9BA5-6E88ABFB18EC@alum.mit.edu>
References: <1425501718-12066-1-git-send-email-msekleta@redhat.com> <54F77336.7040006@plumgrid.com> <6E5AAA23-4000-4C29-BB4E-AA7C05B6F619@alum.mit.edu> <54F7997A.3020604@plumgrid.com> <20150305065053.GA2062@nanopsycho.orion> <20150305072413.GB25656@unicorn.suse.cz>
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Jiri Pirko <jpirko@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Michal Sekletar <msekleta@redhat.com>, netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c.mail.sonic.net ([64.142.111.80]:35748 "EHLO c.mail.sonic.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751390AbbCEIfB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 03:35:01 -0500
In-Reply-To: <20150305072413.GB25656@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mar 4, 2015, at 11:24 PM, Michal Kubecek <mkubecek@suse.cz> wrote:

> To be more precise, it does not need it now as there is no syntax for
> pcap filter on TPID,

In the current version of libpcap (and the commit dates back to November 2011), the filter "vlan" checks both for 0x8100 and 0x9100 (it should perhaps also check for other TPID values), in userland and in the kernel on platforms other than Linux, as the generated code checks for both values.

If there is a way that an in-kernel BPF program can check for all VLAN TPID values, that would be helpful; that would be sufficient to implement the filter "vlan" in a fashion that works the same in the Linux kernel and in other contexts.  (I presume that one can, from the data delivered to a PF_PACKET SOCK_RAW socket, reconstruct the packet as received, with all the VLAN tags in place in the packet just as they were when the packet hit the adapter's transceiver from the network.  If not, that's a *separate* deficiency.)

I'm not currently worried about Backbone Service Instance Tag Control Information right now, as libpcap currently doesn't handle that, so there's no need to, for the generated code for "vlan", actually test what particular TPID value is in the packet, as long as we can test whether there's a VLAN header or not.  In the future, that might be useful.

(BTW, why did the IEEE remove 802.1Q from the IEEE Get program for IEEE 802 standards?

	http://standards.ieee.org/about/get/802/802.1.html

Are they waiting for 802.1Q-2014 to be published?

	http://www.ieee802.org/1/pages/802.1Q-2014.html

And what's the current status of 802.1ad?  Is QinQ deprecated or something?)