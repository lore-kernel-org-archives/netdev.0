From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [PATCH] 2.6.17 missing a call to ieee80211softmac_capabilities from ieee80211softmac_assoc_req
Date: Fri, 23 Jun 2006 14:38:24 -0400
Message-ID: <43e72e890606231138yd26c186tc22b346491fccdcf@mail.gmail.com>
References: <449803E6.5020404@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:24288 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1751907AbWFWSi0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 14:38:26 -0400
Received: by ug-out-1314.google.com with SMTP id a2so1169097ugf
        for <netdev@vger.kernel.org>; Fri, 23 Jun 2006 11:38:24 -0700 (PDT)
To: "Larry Finger" <Larry.Finger@lwfinger.net>
In-Reply-To: <449803E6.5020404@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes Assoc with Cisco Aironet 1200 series Wireless Access Points
as well. Tested with zd1211. Without this the zd1211 was not able to
complete assoc. Nice catch.

  Luis

On 6/20/06, Larry Finger <Larry.Finger@lwfinger.net> wrote:
> In commit ba9b28d19a3251bb1dfe6a6f8cc89b96fb85f683, routine ieee80211softmac_capabilities was added
> to net/ieee80211/softmac/ieee80211softmac_io.c. As denoted by its name, it completes the
> capabilities IE that is needed in the associate and reassociate requests sent to the AP. For at
> least one AP, the Linksys WRT54G V5, the capabilities field must set the 'short preamble' bit or the
> AP refuses to associate. In the commit noted above, there is a call to the new routine from
> ieee80211softmac_reassoc_req, but not from ieee80211softmac_assoc_req. This patch fixes that oversight.
>
> As noted in the subject, v2.6.17 is affected. My bcm43xx card had been unable to associate since I
> was forced to buy a new AP. I finally was able to get a packet dump and traced the problem to the
> capabilities info. Although I had heard that a patch was "floating around", I had not seen it before
> 2.6.17 was released. As this bug does not affect security and I seem to have the only AP affected by
> it, there should be no problem in leaving it for 2.6.18.
>
> Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>
>
> index 0954161..8cc8b20 100644
> --- a/net/ieee80211/softmac/ieee80211softmac_io.c
> +++ b/net/ieee80211/softmac/ieee80211softmac_io.c
> @@ -229,6 +229,9 @@ ieee80211softmac_assoc_req(struct ieee8
>                 return 0;
>         ieee80211softmac_hdr_3addr(mac, &((*pkt)->header), IEEE80211_STYPE_ASSOC_REQ, net->bssid, net->bssid);
>
> +       /* Fill in the capabilities */
> +       (*pkt)->capability = ieee80211softmac_capabilities(mac, net);
> +
>         /* Fill in Listen Interval (?) */
>         (*pkt)->listen_interval = cpu_to_le16(10);
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
