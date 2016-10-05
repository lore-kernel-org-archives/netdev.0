From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next] openvswitch: correctly fragment packet with
 mpls headers
Date: Wed, 5 Oct 2016 14:47:24 +0200
Message-ID: <20161005144724.67a5ab12@griffin>
References: <b0cb6efc9bfda8381af880f10fa6b3447f7d3d5d.1475512190.git.jbenc@redhat.com>
        <CAOrHB_Dh=OPUTbbN7QYo9Nz4cV99-k_fT4z7jSOEcnFEDKXQEg@mail.gmail.com>
        <20161004102458.1241605f@griffin>
        <20161004112804.04f25140@griffin>
        <CAOrHB_C55GM=AfYj43VJ-hPRZfwFxm_+8Ls2+7mck2Js1fy9-w@mail.gmail.com>
        <20161004185920.229e62de@griffin>
        <CAOrHB_Cr7E+_GLtrReUqqG91LV_7yJSWoZhs0pe6N9E0rAxqPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58966 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752666AbcJEMr2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Oct 2016 08:47:28 -0400
In-Reply-To: <CAOrHB_Cr7E+_GLtrReUqqG91LV_7yJSWoZhs0pe6N9E0rAxqPQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 4 Oct 2016 19:03:46 -0700, Pravin Shelar wrote:
> We could have encapsulated packet defragmented in physical bridge.
> that mean the packet is entering OVS after egressing tunnel device.
> That use case would break due to this patch.

Okay, thanks for explanation. I missed this use case and it would
indeed break. And we can't clear existing inner headers when the frame
enters the bridge as it would break GSO.

Seems checking for the MPLS ethertype is indeed the only safe solution.

> > If this patch is wrong, then the current push_mpls is wrong, too, it
> > does the same assumption.
> >
> I am not sure what you mean, can you explain?

push_mpls() uses inner_proto as an indication whether this is the first
MPLS label or not. But it checks skb->encapsulation at the start, thus
it's safe (I expected this check to be done at the config time, not
runtime, and looked in the wrong place for it.)

I'll respin the patch.

Thanks for the patience with me,

 Jiri
