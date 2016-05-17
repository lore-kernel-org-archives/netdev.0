From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net: diag: Tell user if support for destroying TCP
 sockets is not enabled
Date: Mon, 16 May 2016 19:11:58 -0600
Message-ID: <cee7f913-ec7a-9eaf-c2cd-eaaaca0b63fd@cumulusnetworks.com>
References: <1463442791-2399-1-git-send-email-dsa@cumulusnetworks.com>
 <CAKD1Yr1Kk_cJkorZdp2+83GqBhVPW2Rn-nT5_FsFWwdkSvqMiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:37327 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752328AbcEQBMB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 21:12:01 -0400
Received: by mail-ig0-f171.google.com with SMTP id s8so2120632ign.0
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 18:12:01 -0700 (PDT)
In-Reply-To: <CAKD1Yr1Kk_cJkorZdp2+83GqBhVPW2Rn-nT5_FsFWwdkSvqMiQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/16/16 6:49 PM, Lorenzo Colitti wrote:
> On Tue, May 17, 2016 at 8:53 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
>> +#else
>> +static int tcp_diag_destroy(struct sk_buff *in_skb,
>> +                           const struct inet_diag_req_v2 *req)
>> +{
>> +       return -EOPNOTSUPP;
>> +}
>>  #endif
>
> I don't understand why you need this. inet_diag_cmd_exact already
> returns EOPNOTSUPP if tcp_diag_handler.destroy is NULL:
>
>         else if (cmd == SOCK_DIAG_BY_FAMILY)
>                 err = handler->dump_one(in_skb, nlh, req);
>         else if (cmd == SOCK_DESTROY && handler->destroy)
>                 err = handler->destroy(in_skb, req);
>         else
>                 err = -EOPNOTSUPP;
>
> Is this not working for some reason?
>

hmmm.... kernel patch is not needed. Suppression was happening in ss.
