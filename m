From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: md5: add LINUX_MIB_TCPMD5FAILURE counter
Date: Wed, 24 Aug 2016 10:50:32 -0700
Message-ID: <1472061032.14381.112.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472054483.14381.86.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160824103520.56fad551@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Julien Goodwin <julieng@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:36159 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755628AbcHXRue (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 13:50:34 -0400
Received: by mail-pf0-f175.google.com with SMTP id h186so8932328pfg.3
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 10:50:34 -0700 (PDT)
In-Reply-To: <20160824103520.56fad551@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-08-24 at 10:35 -0700, Stephen Hemminger wrote:

> You can't add value in middle of user API enum without breaking
> binary compatibility.

There is no binary compatibility here.

/proc/net/netstat is a text file with a defined format.

First line contains the headers.

If 'binary compatibility 'was an issue, we would not have added anything
in this file.

Programs need to be able to properly parse these TcpExt: lines.
nstat is doing the right thing.

I could put LINUX_MIB_TCPMD5FAILURE at the end, but 'nstat' would have
these MD5 counters in different places.

So for the few people (ie not programs) looking at nstat, it seems
better to place this MIB at this point.
