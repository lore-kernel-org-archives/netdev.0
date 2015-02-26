From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Flows! Offload them.
Date: Thu, 26 Feb 2015 12:39:42 +0100
Message-ID: <20150226113942.GC1973@nanopsycho.lan>
References: <20150226074214.GF2074@nanopsycho.orion>
 <20150226112252.GF9840@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, jpettit@nicira.com,
	joestringer@nicira.com, john.r.fastabend@intel.com,
	jhs@mojatatu.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	simon.horman@netronome.com, shrijeet@gmail.com,
	gospo@cumulusnetworks.com, bcrl@kvack.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:40773 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932091AbbBZLjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 06:39:46 -0500
Received: by wghl18 with SMTP id l18so9807852wgh.7
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 03:39:45 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150226112252.GF9840@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Feb 26, 2015 at 12:22:52PM CET, sowmini.varadhan@oracle.com wrote:
>On (02/26/15 08:42), Jiri Pirko wrote:
>> 6) implement "named sockets" (working name) and implement TC support for that
>>     -ingress qdisc attach, act_mirred target
>> 7) allow tunnels (VXLAN, Geneve, GRE) to be created as named sockets
>
>Can you elaborate a bit on the above two?

Sure. If you look into net/openvswitch/vport-vxlan.c for example, there
is a socket created by vxlan_sock_add. vxlan_rcv is called on rx and
vxlan_xmit_skb to xmit.

What I have on mind is to allow to create tunnels using "ip" but not as
a device but rather just as a wrapper of these functions (and others alike).

To identify the instance we name it (OVS has it identified and vport).
After that, tc could allow to attach ingress qdisk not only to a device,
but to this named socket as well. Similary with tc action mirred, it would
be possible to forward not only to a device, but to this named socket as
well. All should be very light.


>
>FWIW I've been looking at the problem of RDS over TCP, which is
>an instance of layered sockets that tunnels the application payload
>in TCP. 
>
>RDS over IB provides QoS support using the features available in
>IB- to supply an analog of that for RDS-TCP, you'd need to plug
>into tc's CBQ support, and also provide hooks for packet (.1p, dscp)
>marking. 
>
>Perhaps there is some overlap to what you are thinking of in #6 and #7 
>above?

I'm not talking about QoS at all. See the description above.

Jiri

>
>--Sowmini
