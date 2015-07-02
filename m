From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] net: bail on sock_wfree, sock_rfree when we
 have a TCP_TIMEWAIT sk
Date: Thu, 2 Jul 2015 21:47:31 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1507022140100.1649@ja.home.ssi.bg>
References: <1435781589-2210146-1-git-send-email-agartrell@fb.com> <20150701.141402.587634025761326092.davem@davemloft.net> <CANn89iK8SMLFNA6J0WB_qVTB+-C6qoX2o7-CxvwrLVua-cXzWg@mail.gmail.com> <CALCkm3fUmO0pmQEgrwjoNy5PjFk+mzYbUd1wmBsV7hVSHBngPA@mail.gmail.com>
 <CANn89iL4Pr1MQ_7uDcKEyT+D+193cQk9R304JsMAE0od4+ieEQ@mail.gmail.com> <CALCkm3f1nmi-st-siG0CRv32X7G5d6+JCsOWM01Rh3Qif3HtuQ@mail.gmail.com> <alpine.LFD.2.11.1507021135180.2615@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	"agartrell@fb.com" <agartrell@fb.com>,
	netdev <netdev@vger.kernel.org>, kernel-team <kernel-team@fb.com>
To: Alex Gartrell <alexgartrell@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:58154 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754070AbbGBSru (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jul 2015 14:47:50 -0400
In-Reply-To: <alpine.LFD.2.11.1507021135180.2615@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 2 Jul 2015, Julian Anastasov wrote:

> 	Alex, in our discussion on January I thought
> we can skip calling skb_orphan for some cases but as
> input and output path use different skb->destructor
> we should call skb_orphan for every method, in every
> case when skb->dev != NULL, even when we do not call
> LOCAL_OUT, i.e. when NF_ACCEPT is returned for traffic
> to local real server. We should not call it only for
> local socket (skb->dev == NULL).
> 
> 	I think, your patch from January is almost
> good:
> 
> http://archive.linuxvirtualserver.org/html/lvs-devel/2015-01/msg00014.html
> 
> 	Just add skb->dev check and we should be fine.

	Sorry, I overlooked the problem. Above is not
correct because we can avoid the skb_orphan call
when 'local' is true. ip_vs_nat_send_or_cont should
call skb_orphan even for local=true while for TUN
it should be before ip_vs_prepare_tunneled_skb.
All other methods should avoid skb_orphan if
local=true or skb->dev is NULL.

Regards

--
Julian Anastasov <ja@ssi.bg>
