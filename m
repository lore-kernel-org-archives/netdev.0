From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: RE: [PATCH net-next 1/5] vxlan: Make VXLAN default UDP port number
 available for others
Date: Wed, 12 Mar 2014 09:44:26 +0000
Message-ID: <262CB373A6D1F14F9B81E82F74F77D5A46F7A51B@avmb2.qlogic.org>
References: <1394470142-13992-1-git-send-email-shahed.shaikh@qlogic.com>
	<1394470142-13992-2-git-send-email-shahed.shaikh@qlogic.com>
	<CAJZOPZ+MFe2ev372L07uVvXs_wYnqAiZ3VMG4YteD2XmPWHoSQ@mail.gmail.com>
	<262CB373A6D1F14F9B81E82F74F77D5A46F797EE@avmb2.qlogic.org>
	<CAJZOPZKBdZPuEe5uKLb3sw92q3Qko4RS-90uVAQK=+pFXVAfSA@mail.gmail.com>
	<262CB373A6D1F14F9B81E82F74F77D5A46F798F5@avmb2.qlogic.org>
 <20140311082809.73b83228@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Dept-HSG Linux NIC Dev" <Dept-HSGLinuxNICDev@qlogic.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:59015 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753665AbaCLJoh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 05:44:37 -0400
In-Reply-To: <20140311082809.73b83228@nehalam.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> Sent: Tuesday, March 11, 2014 8:58 PM
> To: Shahed Shaikh
> Cc: Or Gerlitz; Joseph Gasparakis; John Fastabend; David Miller; netdev;
> Dept-HSG Linux NIC Dev
> Subject: Re: [PATCH net-next 1/5] vxlan: Make VXLAN default UDP port
> number available for others
> 
...
> 
> Is it possible to do "lazy bind" to port, and set up offload when the first
> VXLAN is created? For most user's they will use one port and multiplex by
> VNI. But there maybe migration scenario's with multiple ports.
> 
Hi Stephen,

If I understand you comment correctly,  does this mean, driver should set up offload only for first N udp ports (here N=1 in case of qlcnic) used by VXLAN driver through vxlan_get_rx_port() -> ndo_add_vxlan_port() and discard subsequent ndo_add_vxlan_port() notification for N+ udp ports?
I see similar implementation in  i40e driver (N = 16).

Thanks,
Shahed

> The kernel made unfortunate choice of non-standard port, and has to stick
> with that. The ip command tries to nudge users to use the correct IANA port,
> therefore correct offload should wait until the first tunnel is created.
