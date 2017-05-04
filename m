From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: Re: [[NET-NEXT]] Added dump function to recognise rpl extension
 header option(63)
Date: Thu, 4 May 2017 14:27:23 +0200
Message-ID: <af9727bf-9987-1046-c2aa-2a8695447fde@osg.samsung.com>
References: <a712ff423471e02a533650ce6d64dc85@ceid.upatras.gr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Richardson <mcr@sandelman.ca>,
        "linux-wpan@vger.kernel.org" <linux-wpan@vger.kernel.org>
To: Andreas Bardoutsos <bardoutsos@ceid.upatras.gr>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ec2-52-27-115-49.us-west-2.compute.amazonaws.com ([52.27.115.49]:52722
        "EHLO osg.samsung.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751353AbdEDM12 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 08:27:28 -0400
In-Reply-To: <a712ff423471e02a533650ce6d64dc85@ceid.upatras.gr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Lets do the review here on netdev.

Some general things first. You might want to use git send-email to make 
sure the formatting does not get screwed up from your mailer. Another 
thing to keep in mind is that net-next is closed right now (we are in 
the 4.12 merge window right now) and Dave will most likely as you to 
re-submit once it opens up again. On the other hand I would go as far as 
calling this a fix as it makes sure the needed packet does not get 
dropped in kernel space and unstrung as RPL daemon can work with it. It 
also fixes the RPL communication with Contiki.

Your subject line also needs a prefix like "ipv6: ext_header:". Maybe 
something like this is better:

ipv6: ext_header: add function to handle RPL option 0x63

On 05/04/2017 02:06 PM, Andreas Bardoutsos wrote:
> Signed-off-by: Andreas Bardoutsos <bardoutsos@ceid.upatras.gr>
> ---
> I have added a dump function(always return true) to recognise RPL
> extension header(RFC6553)
> Otherwise packet was dropped by kernel resulting in impossible
> communication in RPL DAG's between
> linux running border routers and devices in the graph,which may run
> different OS(contiki os for example)

Please put this useful information in the commit message.

>  include/uapi/linux/in6.h |  1 +
>  net/ipv6/exthdrs.c       | 13 +++++++++++++
>  2 files changed, 14 insertions(+)
>
> diff --git a/include/uapi/linux/in6.h b/include/uapi/linux/in6.h
> index 46444f8fbee4..5cc12d309dfe 100644
> --- a/include/uapi/linux/in6.h
> +++ b/include/uapi/linux/in6.h
> @@ -146,6 +146,7 @@ struct in6_flowlabel_req {
>  #define IPV6_TLV_CALIPSO    7    /* RFC 5570 */
>  #define IPV6_TLV_JUMBO        194
>  #define IPV6_TLV_HAO        201    /* home address option */
> +#define IPV6_TLV_RPL    99    /* RFC 6553 */
>
>  /*
>   *    IPV6 socket options
> diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
> index b636f1da9aec..82ed60d3180e 100644
> --- a/net/ipv6/exthdrs.c
> +++ b/net/ipv6/exthdrs.c
> @@ -785,6 +785,15 @@ static bool ipv6_hop_calipso(struct sk_buff *skb,
> int optoff)
>      return false;
>  }
>
> +/* RPL RFC 6553 */
> +
> +static bool ipv6_hop_rpl(struct sk_buff *skb, int optoff)
> +{
> +    /*Dump function which always return true
> +    *when rpl option is detected*/
> +    return true;

We might need to do some more processing later here. For now it should 
be good as a fix to get the RPL communication between Linux and Contiki 
working again. Michael, what extra checks would you need in the kernel here?

> +}
> +
>  static const struct tlvtype_proc tlvprochopopt_lst[] = {
>      {
>          .type    = IPV6_TLV_ROUTERALERT,
> @@ -798,6 +807,10 @@ static const struct tlvtype_proc
> tlvprochopopt_lst[] = {
>          .type    = IPV6_TLV_CALIPSO,
>          .func    = ipv6_hop_calipso,
>      },
> +    {
> +        .type    = IPV6_TLV_RPL,
> +        .func    = ipv6_hop_rpl,
> +    },
>      { -1, }
>  };


Reviewed-by: Stefan Schmidt <stefan@osg.samsung.com>

regards
Stefan Schmidt
