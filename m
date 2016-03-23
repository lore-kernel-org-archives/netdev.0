From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net 1/2] net: bcmgenet: fix dev->stats.tx_bytes accounting
Date: Wed, 23 Mar 2016 15:02:33 -0700
Message-ID: <B161205E-3917-42F9-9831-BA05F94FCCB9@gmail.com>
References: <1458763289-95167-1-git-send-email-pgynther@google.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, jaedon.shin@gmail.com, edumazet@google.com
To: Petri Gynther <pgynther@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33315 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751614AbcCWWCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 18:02:43 -0400
Received: by mail-pf0-f180.google.com with SMTP id 4so40699857pfd.0
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 15:02:42 -0700 (PDT)
In-Reply-To: <1458763289-95167-1-git-send-email-pgynther@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On March 23, 2016 1:01:28 PM PDT, Petri Gynther <pgynther@google.com> wrote:
>1. Add bytes_compl local variable to collect transmitted bytes
>   - dev->stats updates can then be moved outside the while-loop
>   - bytes_compl is also needed for future BQL support
>2. When bcmgenet device uses Tx checksum offload, each transmitted
>   skb has an extra 64-byte header prepended to it. This needs to
>   be deducted when counting transmitted bytes.
>3. skb->len covers the entire length of skb, whether it is linear or
>   fragmented. Thus, when we clean the fragments, do not increase
>   transmitted bytes.
>
>Signed-off-by: Petri Gynther <pgynther@google.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

Fixes: 1c1008c793fa ("net: bcmgenet: add main driver file")

-- 
Florian
