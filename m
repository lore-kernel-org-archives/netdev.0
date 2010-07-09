From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: add CHECKSUM target
Date: Fri, 09 Jul 2010 17:17:36 +0200
Message-ID: <4C373D90.8070000@trash.net>
References: <20100708222913.GA4475@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, herbert.xu@redhat.com, kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100708222913.GA4475@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 09.07.2010 00:29, schrieb Michael S. Tsirkin:
> This adds a `CHECKSUM' target, which can be used in the iptables mangle
> table.
> 
> You can use this target to compute and fill in the checksum in
> an IP packet that lacks a checksum.  This is particularly useful,
> if you need to work around old applications such as dhcp clients,
> that do not work well with checksum offloads, but don't want to
> disable checksum offload in your device.
> 
> The problem happens in the field with virtualized applications.
> For reference, see Red Hat bz 605555, as well as
> http://www.spinics.net/lists/kvm/msg37660.html
> 
> Typical expected use (helps old dhclient binary running in a VM):
> iptables -A POSTROUTING -t mangle -p udp --dport 68 -j CHECKSUM
> --checksum-fill

I'm not sure this is something we want to merge upstream and
support indefinitely. Dave suggested this as a temporary
out-of-tree workaround until the majority of guest dhcp clients
are fixed. Has anything changed that makes this course of
action impractical?

