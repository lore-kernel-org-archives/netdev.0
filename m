From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH PKT_SCHED 4/4]: fix CONFIG_NET_CLS_ACT skb leaks in	HFSC/CBQ
Date: Wed, 19 Jan 2005 14:33:46 +0100
Message-ID: <41EE61BA.4030406@trash.net>
References: <41EDE462.9040602@trash.net> <1106141206.1047.937.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1106141206.1047.937.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

>I dont have time, but please double check that the following still
>applies:
>
>1) A qdisc receiving a STOLEN/QUEUED/SHOT signal from the classification
>result MUST free the packet and immediately stop processing that packet.
>The infrastructure code will clone packets if they want to steal or
>queue it.
>
It does now. Before there were things like "unsigned int len = skb->len"
after the call to tc_classify.

>2) Return code of qdisc from enqueue function need to be dealt with
>care. For example if the packet is localy generated and it is a TCP
>packet you could confuse the stack by telling it the packet was dropped
>because it will retransmit (and some things will happen with the window
>adjustments).
>
TC_ACT_SHOT => NET_XMIT_DROP
TC_ACT_STOLEN | TC_ACT_QUEUED => NET_XMIT_SUCCESS

>3) packets that are dropped because of a full Q should continue to
>return a XMIT_DROP (you want TCP for example to know about this)
>
They do.
