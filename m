From: Jesse Gross <jesse@nicira.com>
Subject: Re: [Pv-drivers] [PATCH] vmxnet3: Enable GRO support.
Date: Fri, 24 Jun 2011 15:47:41 -0700
Message-ID: <BANLkTi=OJSnGQ99cG-QaaxxMp1od3KGCKQ@mail.gmail.com>
References: <1308947605-4300-1-git-send-email-jesse@nicira.com> <03E840D17E263A48A5766AD576E0423A0129262BB5@exch-mbx-111.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	VMware PV-Drivers <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Scott Goldman <scottjg@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:35420 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753957Ab1FXWsC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 18:48:02 -0400
Received: by vxb39 with SMTP id 39so2291414vxb.19
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2011 15:48:01 -0700 (PDT)
In-Reply-To: <03E840D17E263A48A5766AD576E0423A0129262BB5@exch-mbx-111.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 24, 2011 at 3:02 PM, Scott Goldman <scottjg@vmware.com> wro=
te:
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 netif_receive_skb(skb);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 napi_gro_receive(&rq->napi, skb);
>
> So... this doesn't discriminate between if LRO is off or on. =C2=A0Th=
e last time I tried using GRO on top of our hardware LRO, there was act=
ually some minor performance penalty. Do you have any benchmarks showin=
g that this is ok? If not, do you think it might make sense to just do =
gro only if(unlikely(lro is off))?

I ran some benchmarks and do see a slight performance drop with GRO
when LRO is also on, so it seems reasonable to avoid it in that
situation.  I can resubmit with that change.

As an aside, in many cases the hypervisor actually has all of the
information that is necessary to keep LRO on but does not provide it
to the guest.  For example, in the VM-to-VM case the MSS is provided
by the sender as part of the TSO descriptor and if given to the
receiver we could generate a GSO frame and avoid the need to do GRO in
the first place.  Do you know if it is possible to do this?
