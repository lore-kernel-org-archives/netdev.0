From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2.41 5/5] datapath: Add basic MPLS support to kernel
Date: Tue, 1 Oct 2013 17:45:15 -0700
Message-ID: <CAEP_g=9kx+KC8sQKmb5kZ588aOjbqjWEwSXFyrC7jxMW-0bV+w@mail.gmail.com>
References: <1380610064-14856-1-git-send-email-horms@verge.net.au>
 <1380610064-14856-6-git-send-email-horms@verge.net.au> <CAEP_g=-+ttiZnxv95V17KQdN1Pg4UT1P80WSrFGHQWROvj+nMQ@mail.gmail.com>
 <20131002004057.GE5483@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ben Pfaff <blp@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog134.obsmtp.com ([74.125.149.83]:49023 "HELO
	na3sys009aog134.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751559Ab3JBApg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 20:45:36 -0400
Received: by mail-ie0-f171.google.com with SMTP id at1so253004iec.2
        for <netdev@vger.kernel.org>; Tue, 01 Oct 2013 17:45:35 -0700 (PDT)
In-Reply-To: <20131002004057.GE5483@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 1, 2013 at 5:40 PM, Simon Horman <horms@verge.net.au> wrote:
> On Tue, Oct 01, 2013 at 04:02:17PM -0700, Jesse Gross wrote:
>> On Mon, Sep 30, 2013 at 11:47 PM, Simon Horman <horms@verge.net.au> wrote:
>> > @@ -545,6 +662,14 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
>> >                         output_userspace(dp, skb, a);
>> >                         break;
>> >
>> > +               case OVS_ACTION_ATTR_PUSH_MPLS:
>> > +                       err = push_mpls(skb, nla_data(a));
>> > +                       break;
>> > +
>> > +               case OVS_ACTION_ATTR_POP_MPLS:
>> > +                       err = pop_mpls(skb, nla_get_be16(a));
>> > +                       break;
>>
>> I think we need something similar to POP_VLAN here - in the event of
>> an error the skb will have already been freed.
>
> Thanks, though I think you mean that PUSH_MPLS should be similar to
> PUSH_VLAN. I don't think that either pop_mpls() or pop_vlan() free the
> skb on error.

Yes, sorry, that's what I meant.
