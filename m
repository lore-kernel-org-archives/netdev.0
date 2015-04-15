From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] tcp: Allow sk_wmem_alloc to exceed
 sysctl_tcp_limit_output_bytes
Date: Wed, 15 Apr 2015 09:42:08 -0700
Message-ID: <1429116128.7346.110.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1427388414-31077-1-git-send-email-jonathan.davies@citrix.com>
	<1427390070.25985.145.camel@edumazet-glaptop2.roam.corp.google.com>
	<551555E3.80205@citrix.com> <552BC899.8090300@citrix.com>
	<1428933925.3834.6.camel@edumazet-glaptop2.roam.corp.google.com>
	<552BDAC6.2020708@citrix.com>
	<CAFLBxZaDPa0Em6z-bwg1HoLqCU9R_rWD8ri+0sNVgX-Httj_1A@mail.gmail.com>
	<1429108583.15516.304.camel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Jonathan Davies <jonathan.davies@citrix.com>,
	Wei Liu <Wei.Liu2@citrix.com>, George Dunlap <George.Dunlap@eu.citrix.com>,
	netdev <netdev@vger.kernel.org>, James Morris <jmorris@namei.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	David Vrabel <david.vrabel@citrix.com>,
	xen-devel <xen-devel@lists.xenproject.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Malcolm Crossley <malcolm.crossley@citrix.com>,
	Patrick McHardy <kaber@trash.net>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1429108583.15516.304.camel@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-04-15 at 15:36 +0100, Ian Campbell wrote:
> On Wed, 2015-04-15 at 15:19 +0100, George Dunlap wrote:
> > On Mon, Apr 13, 2015 at 4:03 PM, Malcolm Crossley
> [...]
> > > From a networking point of view, the backend is a switch. Is it OK to
> > > consider the packet to have been transmitted from the guest point of
> > > view once the backend is aware of the packet?
> > >
> > > This would help justify the skb_orphan() in the frontend.
> > 
> > This sounds sensible to me, particularly if virtio_net is already doing it.
> 
> I also find Malcolm's argument above pretty compelling.

Yes, and then you'll have to help the virtio ongoing effort trying to
get rid of this skb_orphan()

Basically you're adding head of line blocking, as a single flow is able
to fill your queue.
