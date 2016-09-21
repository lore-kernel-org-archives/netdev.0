From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next V2] net/vxlan: Avoid unaligned access in
 vxlan_build_skb()
Date: Wed, 21 Sep 2016 09:14:59 -0700
Message-ID: <20160921161457.GA17116@ast-mbp.thefacebook.com>
References: <20160920185737.GU8920@oracle.com>
 <4617aca3-8d44-e99a-cc5a-1088b30ae327@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        netdev@vger.kernel.org, jbenc@redhat.com, davem@davemloft.net
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36032 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933125AbcIUQPI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 12:15:08 -0400
Received: by mail-pf0-f195.google.com with SMTP id n24so2569018pfb.3
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 09:15:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4617aca3-8d44-e99a-cc5a-1088b30ae327@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 21, 2016 at 12:10:55PM +0200, Hannes Frederic Sowa wrote:
> On 20.09.2016 20:57, Sowmini Varadhan wrote:
> > The vxlan header may not be aligned to 4 bytes in
> > vxlan_build_skb (e.g., for MLD packets). This patch
> > avoids unaligned access traps from vxlan_build_skb
> > (in platforms like sparc) by making struct vxlanhdr __packed.
> > 
> > Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> 
> Performance wise this should only affect code generation for archs where
> it matters anyway.

I think it's the opposite. Even on x86 compiler will use byte loads.
