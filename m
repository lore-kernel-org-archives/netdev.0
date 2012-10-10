From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/6] vxlan: minor output refactoring
Date: Wed, 10 Oct 2012 09:08:27 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B702A@saturn3.aculab.com>
References: <20121009175637.048993312@vyatta.com> <20121009175714.462171246@vyatta.com> <1349807275.2386.14.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Joe Perches" <joe@perches.com>,
	"Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49425 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752292Ab2JJITH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 04:19:07 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 29369-08 for <netdev@vger.kernel.org>;
 Wed, 10 Oct 2012 09:19:01 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1349807275.2386.14.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Joe Perches
> Sent: 09 October 2012 19:28
> To: Stephen Hemminger
> Cc: David Miller; netdev@vger.kernel.org
> Subject: Re: [PATCH 1/6] vxlan: minor output refactoring
> 
> On Tue, 2012-10-09 at 10:56 -0700, Stephen Hemminger wrote:
> > +static __be32 vxlan_find_dst(struct vxlan_dev *vxlan, struct sk_buff *skb)
> > +{
> > +       const struct ethhdr *eth = (struct ethhdr *) skb->data;
> > +       struct vxlan_fdb *f;
> > +
> > +       if (is_multicast_ether_addr(eth->h_dest) ||
> > +           (f = vxlan_find_mac(vxlan, eth->h_dest)) == NULL)
> > +               return vxlan->gaddr;
> > +       else
> > +               return f->remote_ip;
> > +}
> 
> Bikeshedding:
> 
> This might be simpler to read with a few more lines like:
> 
> static __be32 vxlan_find_dst(struct vxlan_dev *vxlan, struct sk_buff *skb)
> {
> 	const struct ethhdr *eth = (const struct ethhdr *)skb->data;
> 	struct vxlan_fdb *f;
> 
> 	if (is_multicast_ether_addr(eth->h_dest))
> 		return vxlan->gaddr;
> 
> 	f = vxlan_find_mac(vxlan, eth->h_dest);
> 	if (!f)
> 		return vxlan->gaddr;
> 
> 	return f->remote_ip;
> }

or, painting it green:
static __be32 vxlan_find_dst(struct vxlan_dev *vxlan, struct sk_buff *skb)
{
       const struct ethhdr *eth = (struct ethhdr *)skb->data;
       struct vxlan_fdb *f;

       if (!is_multicast_ether_addr(eth->h_dest) &&
           (f = vxlan_find_mac(vxlan, eth->h_dest)) != NULL)
               return f->remote_ip;
       return vxlan->gaddr;
}

	David
