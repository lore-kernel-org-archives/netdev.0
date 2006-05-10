From: Olivier <o.cornu@gmail.com>
Subject: Re: Dscape ieee80211: enabling/disabling the radio
Date: Wed, 10 May 2006 07:29:55 +0200
Message-ID: <7b4bf7ff0605092229p7a8f1bd5j5ebca4d59ceda381@mail.gmail.com>
References: <200605061401.01795.IvDoorn@gmail.com>
	 <200605100001.20180.IvDoorn@gmail.com>
	 <200605091836.10138.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: "Ivo van Doorn" <ivdoorn@gmail.com>, netdev@vger.kernel.org,
	"Jiri Benc" <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:34727 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S964789AbWEJF34 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 May 2006 01:29:56 -0400
Received: by nf-out-0910.google.com with SMTP id b2so1344173nfe
        for <netdev@vger.kernel.org>; Tue, 09 May 2006 22:29:55 -0700 (PDT)
To: "Michael Wu" <flamingice@sourmilk.net>
In-Reply-To: <200605091836.10138.flamingice@sourmilk.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2006/5/10, Michael Wu <flamingice@sourmilk.net>:
> On Tuesday 09 May 2006 18:01, Ivo van Doorn wrote:
> > A user on the forums Olivier Cornu (added to the CC list) has done some
> > investigation into the scanning behaviour of the dscape stack.
> > Basicly the dscape stack is performing active scanning while the device is
> > down, but during the active scan it is sending packets out, or at least
> > attempting to do so. Besides the question if active scanning is preferred
> > over passive scanning while interface is down, active scanning fails
> > because the packets that should be send are being send through the regular
> > xmit routines of the interface. (IFF_UP is not set for the interface)
> >
> > This means that besides enabling the radio which should be done in the
> > driver, the stack should either bring up the interface when doing an active
> > scan, or resort to passive scanning while interface is down.
> >
> If you can passive scan while the interface is down, I don't think it's really
> down. In adm8211, nothing can be sent or received when the interface is down.
> The radio is always off when the interface is down. Taking the interface up
> just for a scan and then taking it back down doesn't sound too good either. I
> think scans should be prohibited while the interface is down, since leaving
> the interface on isn't gonna do anything bad unless you put in the info to
> associate.
>
> -Michael Wu
>

What do you mean exactly by "device is down, but not really down"?
I thought a network device was called "down" when the IFF_UP flag of
its net_device struct was set to 0 (thus not appearing in ifconfig,
among other things). Is there any other alternative understanding of
it being "down" i'm not aware of?

I confirm scanning actively with the device down is possible using
another NIC/driver. Thus I guess it's normal behaviour.
I still have to figure out how to do it using the dscape 802.11 stack
(if it's actually possible)...

Olivier Cornu
