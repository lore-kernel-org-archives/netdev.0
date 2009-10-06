From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [net-next-2.6 PATCH 6/9] vxge: Check if FCS stripping is disabled by the firmware.
Date: Tue, 6 Oct 2009 02:41:26 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7705C16350@nekter>
References: <Pine.GSO.4.10.10910050755480.9377-100000@guinness> <4AC9EEE0.5000601@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:43744 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756220AbZJFGmF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 02:42:05 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4AC9EEE0.5000601@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > - Added a function to check if FCS stripping is disabled by the
> firmware, if
> >   it is not disabled fail driver load.
> >
> > - By default FCS stripping is disabled by the firmware. With this
> assumption
> >   driver decrements the indicated packet length by 4 bytes(FCS
length).
> >
> > - This patch ensures that FCS stripping is disabled during driver
load
> time.
> >
> > Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
> 
> What the big deal about FCS not being stripped ?
[Ram] The minimum frame size that can be received by the hardware is 57
Bytes. A 64 Byte Ethernet frame with the vlan tag and fcs stripped will
result in a 56 Byte frame which will lock up the receive engine. The
work around is to disable fcs stripping in the hardware which is a
privileged operation done with a firmware version that the driver checks
for currently.

Ram
