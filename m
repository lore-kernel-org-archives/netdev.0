From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next v5 02/14] bridge: Add vlan filtering
 infrastructure
Date: Fri, 11 Jan 2013 15:53:54 +0200
Message-ID: <20130111155354.4ff8aeac.shmulik.ladkani@gmail.com>
References: <1357751882-8619-1-git-send-email-vyasevic@redhat.com>
	<1357751882-8619-3-git-send-email-vyasevic@redhat.com>
	<20130110103614.23383079@nehalam.linuxnetplumber.net>
	<50EF0FF7.3080407@redhat.com>
	<50EF1537.7030209@redhat.com>
	<20130110141005.427ccaf9@nehalam.linuxnetplumber.net>
	<50EF6759.2000908@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, stephen@redhat.com,
	bridge@lists.linux-foundation.org, mst@redhat.com
To: vyasevic@redhat.com, Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:55470 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113Ab3AKNyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 08:54:08 -0500
Received: by mail-we0-f177.google.com with SMTP id x48so844986wey.36
        for <netdev@vger.kernel.org>; Fri, 11 Jan 2013 05:54:06 -0800 (PST)
In-Reply-To: <50EF6759.2000908@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, 10 Jan 2013 20:14:01 -0500 Vlad Yasevich <vyasevic@redhat.com> wrote:
> On 01/10/2013 05:10 PM, Stephen Hemminger wrote:
> > Also the concept of different filters for egress vs ingress is feature
> > madness. It doesn't make sense to have half-duplex connectivity.
> 
> I am of the same opinion, but it actually simplified the code quite a 
> bit, but at the cost of additional memory footprint.  If you find this
> very objectionable, I can easily remove it.

Haven't looked on the V5 series yet, but just to clarify:

There's *no* different membership _filter_ for egress vs ingress.
The vlan's membership map is consulted on both ingress and egress.

However, upon egress, a vlan egress _policy_ should be applied, which
determines whether the frame should egress tagged/untagged on the egress
port.

The expected logic in detailed in [1] (please read "steps 1..5").
and the data structures needed are:
  - per port: PVID
  - per VLAN: port membership map
  - per VLAN: port egress policy map

Altough on 1st look it might look mad ;-)
But, this is genuinely simple, highly configurable and allows great
flexibility (IMO with no additional code complexity; Vlad can probably
comment).

The motivation is to be aligned with behavior and configurability of
vlan switches.

Regards,
Shmulik

[1]
http://marc.info/?l=linux-netdev&m=135603447030826&w=2
