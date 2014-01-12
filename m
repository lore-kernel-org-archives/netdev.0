From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: a vxlan question.
Date: Sun, 12 Jan 2014 10:25:03 -0800
Message-ID: <20140112102503.398a0047@nehalam.linuxnetplumber.net>
References: <CACP96tSOA70sAE_b-Ff6=gOySg0sHQQMRwpuNaA1n5HvgFAzSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sowmini.varadhan@hp.com
To: sowmini varadhan <sowmini05@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:53527 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954AbaALSZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 13:25:06 -0500
Received: by mail-pa0-f49.google.com with SMTP id bj1so2940888pad.36
        for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 10:25:05 -0800 (PST)
In-Reply-To: <CACP96tSOA70sAE_b-Ff6=gOySg0sHQQMRwpuNaA1n5HvgFAzSA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 12 Jan 2014 12:25:51 -0500
sowmini varadhan <sowmini05@gmail.com> wrote:

> A question about the vxlan implementation in linux:
> 
> if the inner packet (the frame that is vxlan encapsulated) is an IP
> packet that has the DF bit set, i.e., it is a PMTU discovery packet, and
> the subsequent vxlan encapsulation results in a ICMP packet-too-big
> error,then does the VTEP relay that error back to the originator of
> the
> PMTU packet?
> 
> AFAICT, the current linux code in drivers/net/vxlan.c
> does not address any icmp errors (though it sets the DF of the outer
> header based on the inner header). From my reading of the code,
> we'd end up in __udp4_lib_err for the vxlan-encaps packet, but
> there's nothing in there that recognizes that the udp payload is
> itself an ethernet+IP frame and relays pmtu back to the (inner) ip src?
> Did I miss something?
> 
> --Sowmini
> --

The VXLAN like all layer 2 tunnels is not allowed to respond IP packets
in the inner header. One of the principles of network virtualization
is that the inner network IP space may overlap or be invalid in the
outer IP domain. Therefore an intermediate system (like VXLAN) does
not have a valid IP in the inner domain to send a response.

Another way to look at is that VXLAN is more of L2 bridge rather
than a L3 router.
