From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3] bridge: allow adding of fdb entries pointing
 to the bridge device
Date: Sat, 10 Oct 2015 07:49:43 -0700
Message-ID: <56192587.4000400@cumulusnetworks.com>
References: <1444325932-1577-1-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bAQEDj7P=raMNhAmOk3VCSb5Qi079rLEdkz2DTRXCLp0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Netdev <netdev@vger.kernel.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34654 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbbJJOtp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2015 10:49:45 -0400
Received: by padhy16 with SMTP id hy16so113082973pad.1
        for <netdev@vger.kernel.org>; Sat, 10 Oct 2015 07:49:44 -0700 (PDT)
In-Reply-To: <CAE4R7bAQEDj7P=raMNhAmOk3VCSb5Qi079rLEdkz2DTRXCLp0A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/9/15, 9:52 PM, Scott Feldman wrote:

<snip>
> @@ -640,7 +641,7 @@ static int fdb_fill_info(struct sk_buff *skb, const struct net_bridge *br,
>         ndm->ndm_flags   = fdb->added_by_external_learn ? NTF_EXT_LEARNED : 0;
>         ndm->ndm_type    = 0;
>         ndm->ndm_ifindex = fdb->dst ? fdb->dst->dev->ifindex : br->dev->ifindex;
> -       ndm->ndm_state   = fdb_to_nud(fdb);
> +       ndm->ndm_state   = fdb_to_nud(br, fdb);
>
>         if (nla_put(skb, NDA_LLADDR, ETH_ALEN, &fdb->addr))
>                 goto nla_put_failure;
> @@ -785,7 +786,7 @@ static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
>                 }
>         }
>
> -       if (fdb_to_nud(fdb) != state) {
> +       if (fdb_to_nud(br, fdb) != state) {
>
> Hi Roopa,
>
> Are the above changes to fdb_to_nud() related to the patch subject?
> I was trying to figure out this part of the patch...seems unrelated.
> Is fdb->dst->br now not valid in some cases?
yes, because fdb entries pointing to the bridge will have fdb->dst = NULL.
The rest of the bridge code already handles fdb->dst = NULL. Only this function needed a change.
