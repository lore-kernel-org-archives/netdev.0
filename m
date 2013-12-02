From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net-next] xen-netback: Fix pull size in
 checksum_setup_ip*
Date: Mon, 2 Dec 2013 09:42:34 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD019BC2B@AMSPEX01CL01.citrite.net>
References: <1385751407-9365-1-git-send-email-zoltan.kiss@citrix.com>
 <5298F867.3030200@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Zoltan Kiss <zoltan.kiss@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Jonathan Davies" <Jonathan.Davies@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5298F867.3030200@citrix.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Zoltan Kiss
> Sent: 29 November 2013 20:26
> To: Ian Campbell; Wei Liu; xen-devel@lists.xenproject.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Jonathan Davies;
> Paul Durrant
> Cc: Zoltan Kiss
> Subject: Re: [PATCH net-next] xen-netback: Fix pull size in
> checksum_setup_ip*
> 
> Or would it make sense to drop header_size and use off + something as
> function parameters?
> 

Possibly best not to top-post to your own thread ;-)

Agreed; now that we've gone from mostly 3 variable additions to 2, I don't think we need header_size to neaten things up any more.

  Paul

> Zoli
> 
> On 29/11/13 18:56, Zoltan Kiss wrote:
> > Before checksum setup we need to make sure we have enough data in
> linear
> > buffer, so we do a pull if not. The calculation of the required data counts
> > with skb->network_header, which is the headroom size actually. This is not
> > necessary, and can cause unreasonable pulling. I've also removed
> > MAX_IPOPTLEN, as we only need the base header at that point.
> >
> > Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> >
> > ---
> >   drivers/net/xen-netback/netback.c |   24 ++++++++----------------
> >   1 file changed, 8 insertions(+), 16 deletions(-)
> >
> > diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-
> netback/netback.c
> > index 919b650..adadf76 100644
> > --- a/drivers/net/xen-netback/netback.c
> > +++ b/drivers/net/xen-netback/netback.c
> > @@ -1169,8 +1169,7 @@ static int checksum_setup_ip(struct xenvif *vif,
> struct sk_buff *skb,
> >
> >   	off = sizeof(struct iphdr);
> >
> > -	header_size = skb->network_header + off + MAX_IPOPTLEN;
> > -	maybe_pull_tail(skb, header_size);
> > +	maybe_pull_tail(skb, off);
> >
> >   	off = iph->ihl * 4;
> >
> > @@ -1183,8 +1182,7 @@ static int checksum_setup_ip(struct xenvif *vif,
> struct sk_buff *skb,
> >   		if (recalculate_partial_csum) {
> >   			struct tcphdr *tcph = tcp_hdr(skb);
> >
> > -			header_size = skb->network_header +
> > -				off +
> > +			header_size = off +
> >   				sizeof(struct tcphdr);
> >   			maybe_pull_tail(skb, header_size);
> >
> > @@ -1201,8 +1199,7 @@ static int checksum_setup_ip(struct xenvif *vif,
> struct sk_buff *skb,
> >   		if (recalculate_partial_csum) {
> >   			struct udphdr *udph = udp_hdr(skb);
> >
> > -			header_size = skb->network_header +
> > -				off +
> > +			header_size = off +
> >   				sizeof(struct udphdr);
> >   			maybe_pull_tail(skb, header_size);
> >
> > @@ -1241,8 +1238,7 @@ static int checksum_setup_ipv6(struct xenvif *vif,
> struct sk_buff *skb,
> >
> >   	off = sizeof(struct ipv6hdr);
> >
> > -	header_size = skb->network_header + off;
> > -	maybe_pull_tail(skb, header_size);
> > +	maybe_pull_tail(skb, off);
> >
> >   	nexthdr = ipv6h->nexthdr;
> >
> > @@ -1254,8 +1250,7 @@ static int checksum_setup_ipv6(struct xenvif *vif,
> struct sk_buff *skb,
> >   		case IPPROTO_ROUTING: {
> >   			struct ipv6_opt_hdr *hp = (void *)(skb->data + off);
> >
> > -			header_size = skb->network_header +
> > -				off +
> > +			header_size = off +
> >   				sizeof(struct ipv6_opt_hdr);
> >   			maybe_pull_tail(skb, header_size);
> >
> > @@ -1266,8 +1261,7 @@ static int checksum_setup_ipv6(struct xenvif *vif,
> struct sk_buff *skb,
> >   		case IPPROTO_AH: {
> >   			struct ip_auth_hdr *hp = (void *)(skb->data + off);
> >
> > -			header_size = skb->network_header +
> > -				off +
> > +			header_size = off +
> >   				sizeof(struct ip_auth_hdr);
> >   			maybe_pull_tail(skb, header_size);
> >
> > @@ -1305,8 +1299,7 @@ static int checksum_setup_ipv6(struct xenvif *vif,
> struct sk_buff *skb,
> >   		if (recalculate_partial_csum) {
> >   			struct tcphdr *tcph = tcp_hdr(skb);
> >
> > -			header_size = skb->network_header +
> > -				off +
> > +			header_size = off +
> >   				sizeof(struct tcphdr);
> >   			maybe_pull_tail(skb, header_size);
> >
> > @@ -1324,8 +1317,7 @@ static int checksum_setup_ipv6(struct xenvif *vif,
> struct sk_buff *skb,
> >   		if (recalculate_partial_csum) {
> >   			struct udphdr *udph = udp_hdr(skb);
> >
> > -			header_size = skb->network_header +
> > -				off +
> > +			header_size = off +
> >   				sizeof(struct udphdr);
> >   			maybe_pull_tail(skb, header_size);
> >
> >
