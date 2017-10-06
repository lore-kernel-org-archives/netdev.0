From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net] net: enable interface alias removal via rtnl
Date: Fri, 6 Oct 2017 12:18:44 -0600
Message-ID: <b6c121f1-c585-6fa4-8dc9-8847ea5ee20c@gmail.com>
References: <20171005101940.28550-1-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Oliver Hartkopp <oliver@hartkopp.net>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33355 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752292AbdJFSSr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 14:18:47 -0400
Received: by mail-pg0-f65.google.com with SMTP id b11so9964357pgn.0
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 11:18:47 -0700 (PDT)
In-Reply-To: <20171005101940.28550-1-nicolas.dichtel@6wind.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/5/17 4:19 AM, Nicolas Dichtel wrote:
> IFLA_IFALIAS is defined as NLA_STRING. It means that the minimal length of
> the attribute is 1 ("\0"). However, to remove an alias, the attribute
> length must be 0 (see dev_set_alias()).

why not add a check in dev_set_alias that if len is 1 and the 1
character is '\0' it means remove the alias?

> 
> Let's define the type to NLA_BINARY, so that the alias can be removed.

that changes the uapi
