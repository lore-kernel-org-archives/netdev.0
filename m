From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v2 1/3] net: Add function for parsing the header
 length out of linear ethernet frames
Date: Fri, 5 Sep 2014 16:39:12 -0700
Message-ID: <20140905233910.GA19153@its-macbook-pro.plumgrid.com>
References: <20140905231807.2035.33588.stgit@ahduyck-bv4.jf.intel.com>
 <20140905232017.2035.58501.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, jeffrey.t.kirsher@intel.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:32945 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804AbaIEXjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 19:39:11 -0400
Received: by mail-pd0-f176.google.com with SMTP id w10so7244702pde.7
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 16:39:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140905232017.2035.58501.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 05, 2014 at 07:20:26PM -0400, Alexander Duyck wrote:
> This patch updates some of the flow_dissector api so that it can be used to
> parse the length of ethernet buffers stored in fragments.  Most of the
> changes needed were to __skb_get_poff as it needed to be updated to support
> sending a linear buffer instead of a skb.
> 
> I have split __skb_get_poff into two functions, the first is skb_get_poff
> and it retains the functionality of the original __skb_get_poff.  The other
> function is __skb_get_poff which now works much like __skb_flow_dissect in
> relation to skb_flow_dissect in that it provides the same functionality but
> works with just a data buffer and hlen instead of needing an skb.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
>  include/linux/etherdevice.h |    1 +
>  include/linux/skbuff.h      |    4 +++-
>  include/net/flow_keys.h     |    2 ++
>  net/core/filter.c           |    2 +-
>  net/core/flow_dissector.c   |   46 ++++++++++++++++++++++++++++++-------------
>  net/ethernet/eth.c          |   27 +++++++++++++++++++++++++
>  6 files changed, 66 insertions(+), 16 deletions(-)

names and bpf related bits look good to me
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
