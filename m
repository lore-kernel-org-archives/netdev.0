From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH] datapath: Add basic MPLS support to kernel
Date: Wed, 12 Jun 2013 23:00:56 -0700
Message-ID: <CALnjE+rerp_+Ri107rZXFiJJ2DXs0skZHN=1K15oBJvqh5THrA@mail.gmail.com>
References: <1370851669-32400-1-git-send-email-horms@verge.net.au>
	<CAEP_g=_rC9unxv13xvEL3fpC4i2p9rcSWMo4NOeHFWHsp36QRw@mail.gmail.com>
	<CALnjE+pRpC9J91cjgeOxzp_xZ+_eB+UbtEyea13BjJ47K9Utrg@mail.gmail.com>
	<20130613011921.GA32025@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jesse Gross <jesse@nicira.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Ben Pfaff <blp@nicira.com>,
	Jarno Rajahalme <jarno.rajahalme@nsn.com>,
	Joe Stringer <joe@wand.net.nz>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog108.obsmtp.com ([74.125.149.199]:33817 "HELO
	na3sys009aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932343Ab3FMGA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 02:00:58 -0400
Received: by mail-qe0-f51.google.com with SMTP id a11so4226878qen.38
        for <netdev@vger.kernel.org>; Wed, 12 Jun 2013 23:00:56 -0700 (PDT)
In-Reply-To: <20130613011921.GA32025@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 12, 2013 at 6:19 PM, Simon Horman <horms@verge.net.au> wrote:
> On Wed, Jun 12, 2013 at 06:14:07PM -0700, Pravin Shelar wrote:
>> On Tue, Jun 11, 2013 at 2:26 PM, Jesse Gross <jesse@nicira.com> wrote:
>> > On Mon, Jun 10, 2013 at 1:07 AM, Simon Horman <horms@verge.net.au> wrote:

>> >> @@ -341,10 +376,14 @@ static int netdev_send(struct vport *vport, struct sk_buff *skb)
>> >>                                 nskb = skb->next;
>> >>                                 skb->next = NULL;
>> >>
>> >> -                               skb = __vlan_put_tag(skb, vlan_tx_tag_get(skb));
>> >> +                               if (vlan)
>> >> +                                       skb = __vlan_put_tag(skb, vlan_tx_tag_get(skb));
>> >>                                 if (likely(skb)) {
>> >>                                         len += skb->len;
>> >> -                                       vlan_set_tci(skb, 0);
>> >> +                                       if (mpls)
>> >> +                                               skb->protocol = mpls_protocol;
>> >> +                                       if (vlan)
>> >> +                                               vlan_set_tci(skb, 0);
>> >>                                         dev_queue_xmit(skb);
>> >>                                 }
>> >
>> > The order of setting the protocol field is different from the one
>> > below and I think this one isn't right because it means that the MPLS
>> > protocol can override the vlan.
>> >
>> > Pravin, can you take a look at this as well since you are working in
>> > the same area?
>>
>> I think this compatibility code can be moved to new compat code posted
>> on gre-restructuring code few changes.
>
> Sure that sounds reasonable but I am unsure of the status of those changes
> and I would rather not rely on something that isn't ready to merge yet.

Right. sorry abt delay.
But I think it is much closer now and it would be alot easy to handle
compatibility, so it is worth waiting for.
