From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/5] vxlan: Make VXLAN default UDP port number
 available for others
Date: Tue, 11 Mar 2014 08:28:09 -0700
Message-ID: <20140311082809.73b83228@nehalam.linuxnetplumber.net>
References: <1394470142-13992-1-git-send-email-shahed.shaikh@qlogic.com>
	<1394470142-13992-2-git-send-email-shahed.shaikh@qlogic.com>
	<CAJZOPZ+MFe2ev372L07uVvXs_wYnqAiZ3VMG4YteD2XmPWHoSQ@mail.gmail.com>
	<262CB373A6D1F14F9B81E82F74F77D5A46F797EE@avmb2.qlogic.org>
	<CAJZOPZKBdZPuEe5uKLb3sw92q3Qko4RS-90uVAQK=+pFXVAfSA@mail.gmail.com>
	<262CB373A6D1F14F9B81E82F74F77D5A46F798F5@avmb2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dept-HSG Linux NIC Dev <Dept-HSGLinuxNICDev@qlogic.com>
To: Shahed Shaikh <shahed.shaikh@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:57052 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752325AbaCKP2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 11:28:17 -0400
Received: by mail-pb0-f48.google.com with SMTP id md12so8908452pbc.7
        for <netdev@vger.kernel.org>; Tue, 11 Mar 2014 08:28:12 -0700 (PDT)
In-Reply-To: <262CB373A6D1F14F9B81E82F74F77D5A46F798F5@avmb2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Mar 2014 07:22:31 +0000
Shahed Shaikh <shahed.shaikh@qlogic.com> wrote:

> > -----Original Message-----
> > From: Or Gerlitz [mailto:or.gerlitz@gmail.com]
> > Sent: Tuesday, March 11, 2014 12:12 PM
> > To: Shahed Shaikh; Joseph Gasparakis; John Fastabend
> > Cc: David Miller; netdev; Dept-HSG Linux NIC Dev
> > Subject: Re: [PATCH net-next 1/5] vxlan: Make VXLAN default UDP port
> > number available for others
> > 
> ...
> > >> >
> > >> > Although vxlan module has capability to notify udp ports to other
> > >> > interested net devices using .ndo_add_rx_vxlan_port and
> > >> > .ndo_del_rx_vxlan_port, there could be some devices which support
> > >> > vxlan offload but not interested in updating udp port numbers.
> > >> > This may be because some hardware do not support programming
> > >> > multiple udp ports and their drivers may decide to program only
> > >> > default udp port into adapter. So that adapter, at least, can do
> > >> > offloading for default udp port number.
> > >>
> > >> Indeed, but the default port number can be unused while another port
> > >> is used. The ndo will be invoked only behalf of an actual instancing
> > >> of udp port for listener socket (== destination port you want the hw
> > >> to indentify), what's wrong with support this ndo also for devices
> > >> that supported limited (say
> > >> one) such port?
> > >
> > >
> > >  If driver implements .ndo for udp port and user creates multiple
> > > vxlan device with different udp ports, it may end up programming the
> > > udp port which may not go through the adapter and no offload will
> > > happen. OTOH, if drive does not implement .ndo and if user is aware
> > > that driver  is capable of offloading for default port, he can at least crate
> > vxlan device on top of qlcnic interface  with default udp port. So, there is no
> > chance for other udp port numbers to replace default udp port and disturb
> > offloading.
> > 
> > I see your point, but doesn't this suggests we need to somehow enhance
> > the current framework to let drivers know which vxlan traffic is expected to
> > be received over them according to the current routing rules?
> 
> Agree. Because of this limitation I used default udp port for offloading.
> 
> > I understand this is a bit tricky because  vxlan and routing  are l3 constructs
> > while drivers deal with l2, John/Joseph - what's your thinking here?
> 
> Yes. May be John, Joseph or Stephen can suggest on this.
> 
> Thanks,
> Shahed
> 

Is it possible to do "lazy bind" to port, and set up offload when the
first VXLAN is created? For most user's they will use one port and multiplex
by VNI. But there maybe migration scenario's with multiple ports.

The kernel made unfortunate choice of non-standard port, and has to
stick with that. The ip command tries to nudge users to use the correct IANA
port, therefore correct offload should wait until the first tunnel is created.
