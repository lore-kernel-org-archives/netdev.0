From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC] networking: introduce and use skb_put_data()
Date: Thu, 15 Jun 2017 08:40:01 -0700
Message-ID: <20170615084001.3fc5585c@xeon-e3>
References: <20170615071018.9529-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36471 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750801AbdFOPkI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 11:40:08 -0400
Received: by mail-pf0-f176.google.com with SMTP id x63so9079868pff.3
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 08:40:08 -0700 (PDT)
In-Reply-To: <20170615071018.9529-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Jun 2017 09:10:18 +0200
Johannes Berg <johannes@sipsolutions.net> wrote:

> From: Johannes Berg <johannes.berg@intel.com>
> 
> A common pattern with skb_put() is to just want to memcpy()
> some data into the new space, introduce skb_put_data() for
> this.
> 
> An spatch similar to the one for skb_put_zero() converts many
> of the places using it:
> 
>     @@
>     identifier p, p2;
>     expression len, skb, data;
>     type t, t2;
>     @@
>     (
>     -p = skb_put(skb, len);
>     +p = skb_put_data(skb, data, len);
>     |
>     -p = (t)skb_put(skb, len);
>     +p = skb_put_data(skb, data, len);
>     )
>     (
>     p2 = (t2)p;
>     -memcpy(p2, data, len);
>     |
>     -memcpy(p, data, len);
>     )
> 
>     @@
>     type t, t2;
>     identifier p, p2;
>     expression skb, data;
>     @@
>     t *p;
>     ...
>     (
>     -p = skb_put(skb, sizeof(t));
>     +p = skb_put_data(skb, data, sizeof(t));
>     |
>     -p = (t *)skb_put(skb, sizeof(t));
>     +p = skb_put_data(skb, data, sizeof(t));
>     )
>     (
>     p2 = (t2)p;
>     -memcpy(p2, data, sizeof(*p));
>     |
>     -memcpy(p, data, sizeof(*p));
>     )
> 
>     @@
>     expression skb, len, data;
>     @@
>     -memcpy(skb_put(skb, len), data, len);
>     +skb_put_data(skb, data, len);
> 
> (again, manually post-processed to retain some comments)
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

LGTM

Reviewed-by: Stephen Hemminger <stephen@networkplumber.org>
