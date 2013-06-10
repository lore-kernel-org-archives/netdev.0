From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net v2 01/03] vxlan: only migrate dynamic FDB entries
Date: Mon, 10 Jun 2013 13:32:01 -0700
Message-ID: <20130610133201.30f20a69@nehalam.linuxnetplumber.net>
References: <20130610195822.888424947@vyatta.com>
	<20130610131317.0c17ed0d@nehalam.linuxnetplumber.net>
	<51B63696.7020000@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:51793 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812Ab3FJUcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 16:32:05 -0400
Received: by mail-pd0-f182.google.com with SMTP id r10so1695863pdi.27
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 13:32:05 -0700 (PDT)
In-Reply-To: <51B63696.7020000@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Jun 2013 00:27:02 +0400
Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> wrote:

> Hello.
> 
> On 06/11/2013 12:13 AM, Stephen Hemminger wrote:
> 
> > Only migrate dynamic forwarding table entries, don't modify
> > static entries. If packet received from incorrect source IP address
> > assume it is an imposter and drop it.
> 
> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> > ---
> > Should go to -stable as well.
> 
> > --- a/drivers/net/vxlan.c	2013-06-06 08:27:07.499595174 -0700
> > +++ b/drivers/net/vxlan.c	2013-06-06 09:38:54.291654035 -0700
> > @@ -603,9 +603,10 @@ skip:
> >
> >   /* Watch incoming packets to learn mapping between Ethernet address
> >    * and Tunnel endpoint.
> > + * Return true if packet is bogus and should be droppped.
> >    */
> > -static void vxlan_snoop(struct net_device *dev,
> > -			__be32 src_ip, const u8 *src_mac)
> > +static bool vxlan_snoop(struct net_device *dev,
> > +		       __be32 src_ip, const u8 *src_mac)
> 
>     Not clear why you changed the indentation of the second line...
> 
> WBR, Sergei
> 

It was int, now bool, and second line didn't get reindented.
Now dave will make resend the whole series...
