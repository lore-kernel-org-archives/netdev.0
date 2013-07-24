From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] tuntap: hardware vlan tx support
Date: Wed, 24 Jul 2013 08:11:39 -0700
Message-ID: <20130724081139.28ba3429@nehalam.linuxnetplumber.net>
References: <1374563748-38821-1-git-send-email-jasowang@redhat.com>
	<20130723085310.4a036a47@nehalam.linuxnetplumber.net>
	<51EF6C42.1070304@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Basil Gor <basil.gor@gmail.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:42815 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645Ab3GXPLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 11:11:43 -0400
Received: by mail-pb0-f44.google.com with SMTP id uo1so9862610pbc.17
        for <netdev@vger.kernel.org>; Wed, 24 Jul 2013 08:11:42 -0700 (PDT)
In-Reply-To: <51EF6C42.1070304@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Jul 2013 13:55:14 +0800
Jason Wang <jasowang@redhat.com> wrote:

> On 07/23/2013 11:53 PM, Stephen Hemminger wrote:
> > On Tue, 23 Jul 2013 15:15:48 +0800
> > Jason Wang <jasowang@redhat.com> wrote:
> >
> >> +		struct {
> >> +			__be16 h_vlan_proto;
> >> +			__be16 h_vlan_TCI;
> >> +		} veth;
> > Don't you want to use struct vlan_hdr here? 
> 
> There's no need to care encapsulated proto here. In fact, we just
> emulate the hardware inserting of 802.1Q header. So only skb->vlan_tci
> and skb->vlan_proto needs to be cared.
> > Your definition puts the two fields out of order?
> 
> It's order is same as struct vlan_ethhdr. Did you see any issue?

I was looking at if_vlan.h struct vlan_hdr. The veth structure
is a slice between ether and vlan header.
