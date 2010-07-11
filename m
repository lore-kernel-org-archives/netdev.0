From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] netfilter: add CHECKSUM target
Date: Sun, 11 Jul 2010 13:47:05 +0300
Message-ID: <20100711104705.GA18017@redhat.com>
References: <20100708222913.GA4475@redhat.com>
 <4C373D90.8070000@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, herbert.xu@redhat.com, kvm@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4C373D90.8070000@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 09, 2010 at 05:17:36PM +0200, Patrick McHardy wrote:
> Am 09.07.2010 00:29, schrieb Michael S. Tsirkin:
> > This adds a `CHECKSUM' target, which can be used in the iptables mangle
> > table.
> > 
> > You can use this target to compute and fill in the checksum in
> > an IP packet that lacks a checksum.  This is particularly useful,
> > if you need to work around old applications such as dhcp clients,
> > that do not work well with checksum offloads, but don't want to
> > disable checksum offload in your device.
> > 
> > The problem happens in the field with virtualized applications.
> > For reference, see Red Hat bz 605555, as well as
> > http://www.spinics.net/lists/kvm/msg37660.html
> > 
> > Typical expected use (helps old dhclient binary running in a VM):
> > iptables -A POSTROUTING -t mangle -p udp --dport 68 -j CHECKSUM
> > --checksum-fill
> 
> I'm not sure this is something we want to merge upstream and
> support indefinitely. Dave suggested this as a temporary
> out-of-tree workaround until the majority of guest dhcp clients
> are fixed. Has anything changed that makes this course of
> action impractical?

If I understand what Dave said correctly, it's up to you ...

The arguments for putting this upstream are:

Given the track record, I wouldn't hope for quick fix in the majority of
guest dhcp clients, unfortunately :(.  We are talking years here.
Even after that, one of the uses of virtualization is
to keep old guests running. So yes, I think we'll
keep using work-arounds for this for a very long time.

Further, since we have to add the module and we have to teach management
to program it, it will be much less painful for everyone
involved if we can put the code upstream, rather than forking
management code.

-- 
MST
