From: "Jon Smirl" <jonsmirl@gmail.com>
Subject: Re: e1000 tcp checksum incorrect, x86 64b
Date: Fri, 28 Sep 2007 13:39:34 -0400
Message-ID: <9e4733910709281039n75be6264rdb34124d8c30ab44@mail.gmail.com>
References: <E1Ib79E-0006CN-00@gondolin.me.apana.org.au>
	 <46FD2D3B.4050605@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: "Rick Jones" <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.240]:59673 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085AbXI1Rjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 13:39:36 -0400
Received: by an-out-0708.google.com with SMTP id d31so467514and
        for <netdev@vger.kernel.org>; Fri, 28 Sep 2007 10:39:35 -0700 (PDT)
In-Reply-To: <46FD2D3B.4050605@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/28/07, Rick Jones <rick.jones2@hp.com> wrote:
> Herbert Xu wrote:
> > Jon Smirl <jonsmirl@gmail.com> wrote:
> >
> >>App is writing seven bytes to the socket. Socket write timeout expires
> >>and the seven bytes are sent. The checksum is not getting inserted
> >>into the packet. It is set to a constant 0x8389 instead of the right
> >>value.  App is gmpc 0.15.4.95, Revision: 6794
> >>
> >>Attached Wireshark packet trace show the problem. e1000 is 192.168.1.4
> >>64bit, Q6600. Dell Dimension 9200
> >
> >
> > Wireshark is broken.  It needs to know TP_STATUS_CSUMNOTREADY
> > means that the checksum is partial and will only be completed
> > when the hardware sends the packet out.
> >
> > Alternatively disable checksum offload with ethtool.
>
> Or take the packet traces "outboard" of the NIC somewhere/somehow.
>
> What problem(s) led to your taking the packet trace in the first place?

I was working on the Ethernet driver for another embedded system
attached to the box. I noticed these errors going to my NSLU2 which I
thought was working ok. But now I know they are not real errors.

Ethernet driver for MPC5200 in embedded system still has some
problems. It is being discussed on linuxppc-embedded.

-- 
Jon Smirl
jonsmirl@gmail.com
