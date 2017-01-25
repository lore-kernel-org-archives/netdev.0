From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [Xen-devel] xennet_start_xmit assumptions
Date: Wed, 25 Jan 2017 10:45:46 -0500
Message-ID: <20170125154546.GF2212@oracle.com>
References: <20170118153132.GB9258@oracle.com>
 <20170118192528.GA6847@char.us.oracle.com>
 <de0d7a7db4c24b46838aee7623d5d2a3@AMSPEX02CL03.citrite.net>
 <20170119111426.GA22018@oracle.com>
 <fa531e2ed014488baa10556c724e176c@AMSPEX02CL03.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        Wei Liu <wei.liu2@citrix.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
To: Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:45562 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750768AbdAYPqA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 10:46:00 -0500
Content-Disposition: inline
In-Reply-To: <fa531e2ed014488baa10556c724e176c@AMSPEX02CL03.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/25/17 15:06), Paul Durrant wrote:
> 
>   Making netfront cope with a fully non-linear skb looks like it would
> be quite intrusive and probably not worth it so I opted for just doing
> the ETH_HLEN pull-tail if necessary. Can you check it works for you?

I tested it, and it works fine, but note that DaveM's comments in 
this thread: the DKI is that we *must* provide at least the hard_header_len
in the non-paged part of the skb. So might not even be necessary to handle
the fully non-linear skb (though it's probably prudent to check
and bail for this, as your patch does)

I just posted an RFC patch for fixing the pf_packet layer,
just in case other drivers like xen_netfront dont explicitly
check for this
   http://patchwork.ozlabs.org/patch/719236/
