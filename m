From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: ipv4 ID calculation
Date: Wed, 20 Sep 2017 14:15:17 -0700
Message-ID: <20170920141517.14ff5205@xeon-e3>
References: <CAMB9WxJpwdZ2gFygTdWZmpLoCG0A79ReCbts-phpT76JfTPHsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Harsha Chenji <cjkernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:47429 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751833AbdITVPV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 17:15:21 -0400
Received: by mail-pg0-f47.google.com with SMTP id d8so2373936pgt.4
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 14:15:21 -0700 (PDT)
In-Reply-To: <CAMB9WxJpwdZ2gFygTdWZmpLoCG0A79ReCbts-phpT76JfTPHsQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 18 Sep 2017 20:43:05 -0400
Harsha Chenji <cjkernel@gmail.com> wrote:

> Hi all,
> 
> Where is the ID field of the IPv4 header created when the DF flag is
> set? I am looking at ip_build_and_send_pkt. The code seems to have
> changed in 4.4-rc1:
> 
> if (ip_dont_fragment(sk, &rt->dst)) {
>     iph->frag_off = htons(IP_DF);
>     iph->id = 0;
> } else {
>     iph->frag_off = 0;
>     __ip_select_ident(net, iph, 1);
> }
> 
> old code (executed irrespective of DF or not):
> 
>     ip_select_ident(sock_net(sk), skb, sk);
> 
> The code in Stevens is basically iph->id = htons(ip_ident++) and now
> it seems to be calculated based on a hash + lookup table.
> 
> So where is the id of 0 overwritten when DF is set? Didn't find any
> info in the docs.

IP id doesn't matter if Dont Fragment bit is set. The IP id is used
by receiver (and firewalls) to coalesce fragments by the ID. If DF
is set no system in the path is supposed to fragment. The idea is
to reduce the number of possible cases of fragment collisions.



> P.S. - is this the right mailing list for these kind of questions?

Sort of, the list is more about technical discussions and patches.

You could find more info by using git blame to find the commit that
introduced the change, then read the log for that.
