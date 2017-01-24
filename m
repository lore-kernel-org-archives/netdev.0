From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] uapi: fix signess in ethtool_validate_speed()
Date: Tue, 24 Jan 2017 16:51:58 +0200
Message-ID: <20170124165037-mutt-send-email-mst@kernel.org>
References: <1484918453-5849-1-git-send-email-volodymyr.bendiuga@gmail.com>
 <20170120183606-mutt-send-email-mst@kernel.org>
 <CABHmqqAaram+jGGfAM4qGRSuucxZag-pRoc2aBqgQsnWVzNRUQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, nikolay@cumulusnetworks.com,
        netdev@vger.kernel.org,
        Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>,
        Jonas Johansson <jonas.johansson@westermo.se>
To: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49076 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750897AbdAXOwB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 09:52:01 -0500
Content-Disposition: inline
In-Reply-To: <CABHmqqAaram+jGGfAM4qGRSuucxZag-pRoc2aBqgQsnWVzNRUQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2017 at 03:45:25PM +0100, Volodymyr Bendiuga wrote:
> On Fri, Jan 20, 2017 at 5:36 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> 
>     On Fri, Jan 20, 2017 at 02:20:53PM +0100, Volodymyr Bendiuga wrote:
>     > From: Jonas Johansson <jonas.johansson@westermo.se>
>     >
>     > There is a comparison of speed  variable which
>     > is unsigned, and SPEED_UNKNOWN which is signed.
> 
>     So?
>    
>     >
>     > Signed-off-by: Jonas Johansson <jonas.johansson@westermo.se>
>     > Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
>     > ---
>     >  include/uapi/linux/ethtool.h | 2 +-
>     >  1 file changed, 1 insertion(+), 1 deletion(-)
>     >
>     > diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
>     > index f0db778..1ca4a77 100644
>     > --- a/include/uapi/linux/ethtool.h
>     > +++ b/include/uapi/linux/ethtool.h
>     > @@ -1500,7 +1500,7 @@ enum ethtool_link_mode_bit_indices {
>     >
>     >  #define SPEED_UNKNOWN                -1
>     >
>     > -static inline int ethtool_validate_speed(__u32 speed)
>     > +static inline int ethtool_validate_speed(__s32 speed)
>     >  {
>     >       return speed <= INT_MAX || speed == SPEED_UNKNOWN;
>     >  }
> 
>     Then comparison to INT_MAX does not make sense.
> 
> Why doesn't it make sense?
> 

A signed integer is always <= INT_MAX.


-- 
MST
