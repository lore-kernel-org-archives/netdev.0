From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2] regression in ss output
Date: Mon, 16 Oct 2017 09:20:58 -0700
Message-ID: <20171016092058.470f3424@xeon-e3>
References: <AM4PR0901MB125261BF480B49D2BA2DF46BCC480@AM4PR0901MB1252.eurprd09.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Humberto Alves <hjalves@live.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:50703 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756042AbdJPQVC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 12:21:02 -0400
Received: by mail-pf0-f179.google.com with SMTP id b6so7754446pfh.7
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 09:21:02 -0700 (PDT)
In-Reply-To: <AM4PR0901MB125261BF480B49D2BA2DF46BCC480@AM4PR0901MB1252.eurprd09.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Oct 2017 09:57:37 +0000
Humberto Alves <hjalves@live.com> wrote:

> Hi! With the last iproute2 release, ss command output does not 
> differentiate between any-address IPv4 sockets from the IPv6 ones.
> I don't know if this is an expected behaviour, but the old output looks 
> more useful. Below I pasted the difference between the old behaviour and 
> the new one.
> I am happy to send a patch if you want. Thanks
> 
> 
> iproute2-4.12
> -------------
> 
> $ ss --version
> ss utility, iproute2-ss170705
> 
> $ ss -ntl
> State       Recv-Q Send-Q Local Address:Port               Peer 
> Address:Port
> LISTEN      0      100            *:587                        *:* 
> 
> LISTEN      0      100            *:110                        *:* 
> 
> LISTEN      0      100            *:143                        *:* 
> 
> LISTEN      0      128            *:80                         *:* 
> 
> LISTEN      0      128            *:2225                       *:* 
> 
> LISTEN      0      10     127.0.0.1:5010                       *:* 
> 
> LISTEN      0      128            *:20                         *:* 
> 
> LISTEN      0      128    127.0.0.1:20150                      *:* 
> 
> LISTEN      0      128            *:61719                      *:* 
> 
> LISTEN      0      100            *:25                         *:* 
> 
> LISTEN      0      3              *:1723                       *:* 
> 
> LISTEN      0      128            *:17500                      *:* 
> 
> LISTEN      0      128    127.0.0.1:17600                      *:* 
> 
> LISTEN      0      128            *:8000                       *:* 
> 
> LISTEN      0      100            *:993                        *:* 
> 
> LISTEN      0      128    127.0.0.1:17603                      *:* 
> 
> LISTEN      0      100            *:995                        *:* 
> 
> LISTEN      0      100           :::587                       :::* 
> 
> LISTEN      0      100           :::110                       :::* 
> 
> LISTEN      0      100           :::143                       :::* 
> 
> LISTEN      0      128           :::22000                     :::* 
> 
> LISTEN      0      128           :::80                        :::* 
> 
> LISTEN      0      128           :::2225                      :::* 
> 
> LISTEN      0      128           :::20                        :::* 
> 
> LISTEN      0      128          ::1:20150                     :::* 
> 
> LISTEN      0      100           :::25                        :::* 
> 
> LISTEN      0      128           :::17500                     :::* 
> 
> LISTEN      0      128           :::8384                      :::* 
> 
> LISTEN      0      100           :::993                       :::* 
> 
> LISTEN      0      100           :::995                       :::*
> 
> iproute2-4.13
> -------------
> 
> $ ss --version
> ss utility, iproute2-ss170905
> 
> $ ss -ntl
> State       Recv-Q Send-Q Local Address:Port               Peer 
> Address:Port
> LISTEN      0      100            *:587                        *:* 
> 
> LISTEN      0      100            *:110                        *:* 
> 
> LISTEN      0      100            *:143                        *:* 
> 
> LISTEN      0      128            *:80                         *:* 
> 
> LISTEN      0      128            *:2225                       *:* 
> 
> LISTEN      0      10     127.0.0.1:5010                       *:* 
> 
> LISTEN      0      128            *:20                         *:* 
> 
> LISTEN      0      128    127.0.0.1:20150                      *:* 
> 
> LISTEN      0      128            *:61719                      *:* 
> 
> LISTEN      0      100            *:25                         *:* 
> 
> LISTEN      0      3              *:1723                       *:* 
> 
> LISTEN      0      128            *:17500                      *:* 
> 
> LISTEN      0      128    127.0.0.1:17600                      *:* 
> 
> LISTEN      0      128            *:8000                       *:* 
> 
> LISTEN      0      100            *:993                        *:* 
> 
> LISTEN      0      128    127.0.0.1:17603                      *:* 
> 
> LISTEN      0      100            *:995                        *:* 
> 
> LISTEN      0      100            *:587                        *:* 
> 
> LISTEN      0      100            *:110                        *:* 
> 
> LISTEN      0      100            *:143                        *:* 
> 
> LISTEN      0      128            *:22000                      *:* 
> 
> LISTEN      0      128            *:80                         *:* 
> 
> LISTEN      0      128            *:2225                       *:* 
> 
> LISTEN      0      128            *:20                         *:* 
> 
> LISTEN      0      128        [::1]:20150                      *:* 
> 
> LISTEN      0      100            *:25                         *:* 
> 
> LISTEN      0      128            *:17500                      *:* 
> 
> LISTEN      0      128            *:8384                       *:* 
> 
> LISTEN      0      100            *:993                        *:* 
> 
> LISTEN      0      100            *:995                        *:*

All changes are not regressions.

Yes it was intentional because the outputing  [::]:20 looked ugly and using * makes IPv4 and IPv6
look the same.
