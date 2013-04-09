From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 1/3] if.h: add IFF_BRIDGE_RESTRICTED flag
Date: Tue, 09 Apr 2013 08:57:45 -0400
Message-ID: <51641049.3030100@mojatatu.com>
References: <1365442863-32394-1-git-send-email-antonio@open-mesh.com> <1365442863-32394-2-git-send-email-antonio@open-mesh.com> <CAOaVG17nHuoRsf2Kss6LnpgC-Aojcso_zLYyBa18Vn9CGGY+GA@mail.gmail.com> <20130409075606.GB3771@open-mesh.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Antonio Quartulli <antonio@open-mesh.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f169.google.com ([209.85.210.169]:61620 "EHLO
	mail-ia0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760149Ab3DIM6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 08:58:05 -0400
Received: by mail-ia0-f169.google.com with SMTP id y26so2166325iab.0
        for <netdev@vger.kernel.org>; Tue, 09 Apr 2013 05:58:03 -0700 (PDT)
In-Reply-To: <20130409075606.GB3771@open-mesh.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Consider using tc for this.
You can tag the packet using skb mark on the receiving end point,
match them on the bridge and execute actions not to forward them.

cheers,
jamal

On 13-04-09 03:56 AM, Antonio Quartulli wrote:
> On Mon, Apr 08, 2013 at 11:58:48 -0700, Stephen Hemminger wrote:
>> The standard way to do this is to use netfilter. Considering the
>> additional device flags and skb flag changes, I am not sure that your
>> method is better.
>
> To make it a bit more clear:
>
> 1) the skb flag will be used on the "receiving end-point" by batman-adv to mark
> received packets and so instruct the bridge to do not forward them to restricted
> interfaces.
>
> 2) the IFF_ flag is used by batman-adv on the "sending side" to determine
> whether a packet has been originated by a restricted interface and so instruct
> the remote endpoint to mark the skb when received.
>
> 3) to make the bridge code general enough, I decided to let it mark packets
> coming from restricted interfaces as well so that it can also apply the policy
> at 1) locally, without any further setting. The logic described in 1) is
> therefore applied by the bridge even for local packets (not passing through
> batman-adv)
>
>
>
> Point 3) is the only one where netfilter might help. But using two mechanism to
> achieve one goal looked not sane to me and therefore I decided to to do it this
> way. And actually the code allowing point 3 is only:
>
> +       skb->bridge_restricted = !!(skb->dev->flags & IFF_BRIDGE_RESTRICTED);
>
>
> I hope this summary did not create further confusion :)
>
