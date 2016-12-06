From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH iproute2/net-next 3/3] tc: flower: support matching on
 ICMP type and code
Date: Tue, 6 Dec 2016 11:18:57 +0100
Message-ID: <20161206101856.GA1910@penelope.horms.nl>
References: <1480703079-25422-1-git-send-email-simon.horman@netronome.com>
 <1480703079-25422-4-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37157 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751277AbcLFKTB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 05:19:01 -0500
Received: by mail-wm0-f52.google.com with SMTP id t79so119693126wmt.0
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 02:19:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1480703079-25422-4-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 02, 2016 at 07:24:39PM +0100, Simon Horman wrote:
> Support matching on ICMP type and code.
> 
> Example usage:
> 
> tc qdisc add dev eth0 ingress
> 
> tc filter add dev eth0 protocol ip parent ffff: flower \
> 	indev eth0 ip_proto icmp type 8 code 0 action drop
> 
> tc filter add dev eth0 protocol ipv6 parent ffff: flower \
> 	indev eth0 ip_proto icmpv6 type 128 code 0 action drop
> 
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

This series no longer applies to net-next.

...

> @@ -524,6 +597,12 @@ static void flower_print_port(FILE *f, char *name, struct rtattr *attr)
>  		fprintf(f, "\n  %s %d", name, ntohs(rta_getattr_u16(attr)));
>  }
>  
> +static void flower_print_icmp(FILE *f, char *name, struct rtattr *attr)
> +{
> +	if (attr)
> +		fprintf(f, "\n  %s %d", name, ntohs(rta_getattr_u8(attr)));

ntohs() should be removed from the above as its argument is a u8.

...
