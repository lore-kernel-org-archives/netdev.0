From: Vince Laviano <vlaviano@cisco.com>
Subject: Re: igmp kernel issues.
Date: Wed, 21 Aug 2002 10:23:37 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0208211009520.9128-100000@dhcp-128-107-163-94.cisco.com>
References: <4.2.0.58.20020820135148.02f70ed8@193.133.49.25>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Tom Parker <tom@rooted.net>
In-Reply-To: <4.2.0.58.20020820135148.02f70ed8@193.133.49.25>
List-Id: netdev.vger.kernel.org


Hi Tom,

One possible culprit is the following code from the beginning of
ip_rcv_finish(), called for incoming packets after they go through
netfilter, in ip_input.c:

/*
 *      Initialise the virtual path cache for the packet. It describes
 *      how the packet travels inside Linux networking.
 */
 if (skb->dst == NULL) {
	 if (ip_route_input(skb, iph->daddr, iph->saddr, iph->tos, dev))
                        goto drop;
        }
 }

Vince


On Tue, 20 Aug 2002, Tom Parker wrote:
>
> Ive been given this address by Alan Cox in regard to some linux kernel
> networking
> issues..  Follows is the original question I put to Alan:
>
> ---
> Im currently rewriting large parts of mrouted for a custom application.
> One of the functions im implementing is a "promiscuous" mode,
> where by mrouted will service IGMP requests from any subnet, even
> if there is no explicit route for the subnet in the kernel routing tables.
>
> Currently the kernel dosnt seem to pass IGMP reports to user space
> unless there is a route for the subnet of the host which the report came
> from.
>
> Ive searched through ipmr.c and igmp.c to find where its dropping the
> IGMP report but havnt found anything obvious.. Do you know where
> it does this?
> ---
>
> Any additional information on this is greatly appreciated.
>
> Thanks in advance
> Tom Parker
>
>
