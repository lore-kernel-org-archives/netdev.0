From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next RFC 1/2] fib: introduce fib notification
 infrastructure
Date: Tue, 06 Sep 2016 18:14:42 +0200
Message-ID: <1473178482.3643404.717346777.75BB9F60@webmail.messagingengine.com>
References: <1473163300-2045-1-git-send-email-jiri@resnulli.us>
 <1473163300-2045-2-git-send-email-jiri@resnulli.us>
 <6a4d9ba6-7113-b487-eb52-ca1f703d13f6@cumulusnetworks.com>
 <20160906144408.GH1692@nanopsycho>
 <d75d345a-0571-81cb-63c8-f06ada45f252@cumulusnetworks.com>
 <20160906154939.GD1972@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, linville@tuxdriver.com, tgraf@suug.ch,
        gospo@cumulusnetworks.com, sfeldma@gmail.com, ast@plumgrid.com,
        edumazet@google.com, f.fainelli@gmail.com, jhs@mojatatu.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@intel.com,
        andrew@lunn.ch, ivecera@redhat.com,
        YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
To: Jiri Pirko <jiri@resnulli.us>,
        David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:46308 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933625AbcIFQOo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 12:14:44 -0400
In-Reply-To: <20160906154939.GD1972@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 6, 2016, at 17:49, Jiri Pirko wrote:
> Tue, Sep 06, 2016 at 05:11:11PM CEST, dsa@cumulusnetworks.com wrote:
> >On 9/6/16 8:44 AM, Jiri Pirko wrote:
> >> Tue, Sep 06, 2016 at 04:32:12PM CEST, dsa@cumulusnetworks.com wrote:
> >>> On 9/6/16 6:01 AM, Jiri Pirko wrote:
> >>>> From: Jiri Pirko <jiri@mellanox.com>
> >>>>
> >>>> This allows to pass information about added/deleted fib entries to
> >>>> whoever is interested. This is done in a very similar way as devinet
> >>>> notifies address additions/removals.
> >>>>
> >>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> >>>> ---
> >>>>  include/net/ip_fib.h | 19 +++++++++++++++++++
> >>>>  net/ipv4/fib_trie.c  | 43 +++++++++++++++++++++++++++++++++++++++++++
> >>>>  2 files changed, 62 insertions(+)
> >>>>
> >>>
> >>> The notifier infrastructure should be generalized for use with IPv4 and IPv6. While the data will be family based, the infra can be generic.
> >>>
> >> 
> >> Yeah, that I thought about as well. Thing is, ipv6 notifier has to be
> >> atomic. That is the reason we have:
> >> inetaddr_chain and register_inetaddr_notifier (blocking notifier)
> >> inet6addr_chain and register_inet6addr_notifier (atomic notifier)
> >> 
> >
> >Why is IPv6 atomic? Looking at code paths for adding addresses seems like all of the locks are dropped before the notifier is called and adding and deleting ipv6 addresses does not show a hit with this WARN_ON:
> 
> 
> Maybe historic reasons. Would be good to unite the notifiers then. I'll
> look at it.

We add IPs and routes from bottom half layer because of neighbour
discovery router advertisements. They need to run in atomic context
without sleeping.

Bye,
Hannes
