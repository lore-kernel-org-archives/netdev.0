From: Harsha Chenji <cjkernel@gmail.com>
Subject: ipv4 ID calculation
Date: Mon, 18 Sep 2017 20:43:05 -0400
Message-ID: <CAMB9WxJpwdZ2gFygTdWZmpLoCG0A79ReCbts-phpT76JfTPHsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:56407 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750733AbdISAnI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 20:43:08 -0400
Received: by mail-it0-f46.google.com with SMTP id g18so469621itg.5
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 17:43:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Where is the ID field of the IPv4 header created when the DF flag is
set? I am looking at ip_build_and_send_pkt. The code seems to have
changed in 4.4-rc1:

if (ip_dont_fragment(sk, &rt->dst)) {
    iph->frag_off = htons(IP_DF);
    iph->id = 0;
} else {
    iph->frag_off = 0;
    __ip_select_ident(net, iph, 1);
}

old code (executed irrespective of DF or not):

    ip_select_ident(sock_net(sk), skb, sk);

The code in Stevens is basically iph->id = htons(ip_ident++) and now
it seems to be calculated based on a hash + lookup table.

So where is the id of 0 overwritten when DF is set? Didn't find any
info in the docs.

P.S. - is this the right mailing list for these kind of questions?

Thanks!
