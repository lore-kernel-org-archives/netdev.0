From: Vivek Venkatraman <vivek@cumulusnetworks.com>
Subject: Re: [PATCH net-next 8/8] ipmpls: Basic device for injecting packets
 into an mpls tunnel
Date: Thu, 5 Mar 2015 01:17:59 -0800
Message-ID: <CAMs_D1-KtgYEG4-4H7L6uWmUYw-vM2pnqVfDJJECPR+v6Y4QTw@mail.gmail.com>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
	<87lhjlvriq.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	roopa <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	santiago@crfreenet.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:43474 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932068AbbCEJSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 04:18:01 -0500
Received: by wibhm9 with SMTP id hm9so13614075wib.2
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 01:17:59 -0800 (PST)
In-Reply-To: <87lhjlvriq.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is great to see an MPLS data plane implementation make it into the
kernel. I have a couple of questions on this patch.

On Wed, Feb 25, 2015 at 9:18 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
>
>
> Allow creating an mpls tunnel endpoint with
>
> ip link add type ipmpls.
>
> This tunnel has an mpls label for it's link layer address, and by
> default sends all ingress packets over loopback to the local MPLS
> forwarding logic which performs all of the work.
>

Is it correct that to achieve IPoMPLS, each LSP has to be installed as
a link/netdevice?

If ingress packets loopback with the label associated with the link to
hit the MPLS forwarding logic, how does it work if each packet has to
be then forwarded with a different label stack? One use case is a
common IP/MPLS application such as L3VPNs (RFC 4364) where multiple
VPNs may reside over the same LSP, each having its own VPN (inner)
label.

> Ingress IPv4, IPv6 and MPLS packets are supported.
>
> A new arp type ARPHRD_MPLS is defined for network devices that
> whose link-layer addresses is an mpls label stack.
>
> This is the most bare bones version of this tunnel device I can think
> of.  Not even packet counters have been implemented. Offloads
> and features in general are not supported, just to keep it simple and
> obviously correct to start with.  In principle it should be able to
> allow binding to a physical network device and pass all of the
> offloads through ipmpls like the vlan, macvlan, or even ipvlan does.
> Allowing a very fast light weight connection to the network.
>
> The technical tricky bit to residing over something besides
> the loopback device is how to get the next-hop mac address.
> Neighbour table integration?  Something else?
>

Thanks,
Vivek
