From: Greg KH <greg@kroah.com>
Subject: Re: Understanding what's going on when using a Huawei E173 USB 3G
 web-stick (UMTS/HSPA)
Date: Sat, 15 Nov 2014 12:07:11 -0800
Message-ID: <20141115200711.GA24643@kroah.com>
References: <CA+icZUXgLhuVSs0aqxi_e=GLZh-zX3JPMhDF+03ctr7O-Ae2og@mail.gmail.com>
 <1415120132.31049.11.camel@dcbw.local>
 <CA+icZUW2iRkoAK10ayJ9PFuFGWBQzKdFe+8mfd=8oKkAp1txtg@mail.gmail.com>
 <CA+icZUX6caBKnjMv6V_26y_-VNfDqkeXFXKJhDdQpZy7W4oofw@mail.gmail.com>
 <1415981880.22965.28.camel@dcbw.local>
 <CA+icZUUWK8R0zFLBHfvfE6zmZ7=+yP_FJgkkeELVbwdhPUYfRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-usb@vger.kernel.org,
	Aleksander Morgado <aleksander@aleksander.es>
To: Sedat Dilek <sedat.dilek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:46525 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754436AbaKOUHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Nov 2014 15:07:14 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 0FD13208BB
	for <netdev@vger.kernel.org>; Sat, 15 Nov 2014 15:07:13 -0500 (EST)
Content-Disposition: inline
In-Reply-To: <CA+icZUUWK8R0zFLBHfvfE6zmZ7=+yP_FJgkkeELVbwdhPUYfRA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 15, 2014 at 10:23:55AM +0100, Sedat Dilek wrote:
> On Fri, Nov 14, 2014 at 5:18 PM, Dan Williams <dcbw@redhat.com> wrote:
> > On Fri, 2014-11-14 at 11:56 +0100, Sedat Dilek wrote:
> >> On Wed, Nov 12, 2014 at 2:21 PM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
> >> > On Tue, Nov 4, 2014 at 5:55 PM, Dan Williams <dcbw@redhat.com> wrote:
> >> >> On Tue, 2014-11-04 at 16:11 +0100, Sedat Dilek wrote:
> >> >>> Hi,
> >> >>>
> >> >>> I wanted to understand what is going on the kernel-side when
> >> >>> connecting to the Internet via a Huawei E173 USB web-stick (3rd
> >> >>> Generation: UMTS / HSPA).
> >> >>>
> >> >>> Especially the correlation between the diverse USB/NET kernel-drivers
> >> >>> and how the networking is setup.
> >> >>
> >> >
> >> > [ Sitting in front of a foreign Windows machine ]
> >> >
> >> > [ CC Aleksander ]
> >> >
> >> > Hi Dan,
> >> >
> >> > sorry for the late (and short) response.
> >> >
> >> > AFAICS you have given a "skeleton" for a "usb-wwan-networking"
> >> > documentation :-).
> >> >
> >> > Personally, I would like to take into account some kernel-config
> >> > options and some more things.
> >> >
> >>
> >> I started with documenting...
> >>
> >> I have still some difficulties in understanding USB WWAN Networking.
> >> So, this is what I revealed...
> >>
> >> ##### USB: HUAWEI E173 3G/UMTS/HSPA INTERNET STICK
> >>
> >> ### USB-NETWORKING AND WWAN SETUP
> >> CONFIG_USB_USBNET=m        <--- usb networking
> >> CONFIG_USB_NET_CDCETHER=m  <--- usb-wwan (net) configuration
> >> CONFIG_USB_SERIAL_WWAN=m   <--- usb-wwan (serial) configuration
> >> CONFIG_USB_SERIAL_OPTION=m <--- usb-serial driver called "option"
> >
> > Most WWAN devices actually require option, because most WWAN devices
> > have "serial" ports (even if they aren't used for PPP), and 'option' is
> > the driver that handles this.  The 'option' name is historic, but the
> > driver should really be called something like 'wwan-serial-generic' or
> > something like that.
> >
> 
> Is there sth. against renaming the "option" driver to "wwan-serial-generic"?

Yes, people's scripts might break that are hard-coded to use the
"option" driver.

thanks,

greg "here, have a vowel, they are cheap" k-h
