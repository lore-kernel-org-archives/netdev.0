From: Alex Gartrell <alexgartrell@gmail.com>
Subject: Re: [PATCH net-next] net: bail on sock_wfree, sock_rfree when we have
 a TCP_TIMEWAIT sk
Date: Thu, 2 Jul 2015 14:18:55 -0700
Message-ID: <CALCkm3c8N0HE774TU96wjdC_wrkDOwAHEDaSOS+eVJD22zCXmg@mail.gmail.com>
References: <1435781589-2210146-1-git-send-email-agartrell@fb.com>
 <20150701.141402.587634025761326092.davem@davemloft.net> <CANn89iK8SMLFNA6J0WB_qVTB+-C6qoX2o7-CxvwrLVua-cXzWg@mail.gmail.com>
 <CALCkm3fUmO0pmQEgrwjoNy5PjFk+mzYbUd1wmBsV7hVSHBngPA@mail.gmail.com>
 <CANn89iL4Pr1MQ_7uDcKEyT+D+193cQk9R304JsMAE0od4+ieEQ@mail.gmail.com>
 <CALCkm3f1nmi-st-siG0CRv32X7G5d6+JCsOWM01Rh3Qif3HtuQ@mail.gmail.com> <alpine.LFD.2.11.1507021135180.2615@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	"agartrell@fb.com" <agartrell@fb.com>,
	netdev <netdev@vger.kernel.org>, kernel-team <kernel-team@fb.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:33648 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753448AbbGBVTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 17:19:15 -0400
Received: by qgat90 with SMTP id t90so20025856qga.0
        for <netdev@vger.kernel.org>; Thu, 02 Jul 2015 14:19:15 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.11.1507021135180.2615@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 2, 2015 at 1:44 AM, Julian Anastasov <ja@ssi.bg> wrote:
>         I think, your patch from January is almost
> good:

I'll rebase it, add your other suggestions, test it, and send it in.

> And the patch from Eric for IPVS looks good too.

Are we sure that we want to change the semantics of set_owner_w to
orphan it?  It works for us but that's not the behavior I'd expect
from that function and might burn someone later?

I've actually been looking through the code more for other uses of
set_owner_w and I noticed this weird quirk:

The test was simple:
0) Enable ip_forward
1) Add an address to loopback and listen on it
2) Accept a connection and close it (creating a TIME-WAIT socket)
3) Add a new route to a gre tunnel

If early demux was enabled, we'd use the route from the socket
If early demux was disabled, we'd forward using the gre tunnel

Should we just replicate this behavior in ipvs?

if (!skb->dev && skb->sk) return NF_ACCEPT;

-- 
Alex Gartrell <agartrell@fb.com>
