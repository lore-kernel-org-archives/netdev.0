From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH PKT_SCHED 4/4]: fix CONFIG_NET_CLS_ACT skb leaks in
	HFSC/CBQ
Date: 19 Jan 2005 08:26:46 -0500
Message-ID: <1106141206.1047.937.camel@jzny.localdomain>
References: <41EDE462.9040602@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41EDE462.9040602@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I dont have time, but please double check that the following still
applies:

1) A qdisc receiving a STOLEN/QUEUED/SHOT signal from the classification
result MUST free the packet and immediately stop processing that packet.
The infrastructure code will clone packets if they want to steal or
queue it.
2) Return code of qdisc from enqueue function need to be dealt with
care. For example if the packet is localy generated and it is a TCP
packet you could confuse the stack by telling it the packet was dropped
because it will retransmit (and some things will happen with the window
adjustments).
3) packets that are dropped because of a full Q should continue to
return a XMIT_DROP (you want TCP for example to know about this)

cheers,
jamal

On Tue, 2005-01-18 at 23:38, Patrick McHardy wrote:
> # This is a BitKeeper generated diff -Nru style patch.
> #
