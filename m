From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next v3 5/5] r8169: support RTL8411
Date: Mon, 16 Apr 2012 14:58:44 +0800
Message-ID: <E2A7860223AF4B52AFE7946163746F02@realtek.com.tw>
References: <1333089184-1773-5-git-send-email-hayeswang@realtek.com> <1333090086-1815-1-git-send-email-hayeswang@realtek.com> <20120330072521.GA11548@electric-eye.fr.zoreil.com> <52E71C7B42A44FB1A8556BB6B75CD9A0@realtek.com.tw> <20120405083743.GB32027@electric-eye.fr.zoreil.com> <20120409180229.GA28837@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:56403 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750823Ab2DPG6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2012 02:58:52 -0400
In-Reply-To: <20120409180229.GA28837@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Tuesday, April 10, 2012 2:02 AM
> To: Hayeswang
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH net-next v3 5/5] r8169: support RTL8411
[...]
> 
> Rx/Tx is ok, WoL + shutdown is ok but runtime power management is not.
> 
[...]
> 
> - set a 8402 and a 8411 in the same test box
> - ip addr add ... 
> - ip link set dev ... up 
> - start ping from remote host
> - echo auto > /sys/bus/pci/devices/.../power/control
> - unplug cable
>   - ping stops flowing
>   - cat /sys/bus/pci/devices/.../power/runtime_status
>     -> "active"
> - plug cable
>   -> RPM status does not change, no link, no packet, no fun.
> 

The 8111C and the later chips have to set Config2 (0x53) bit 5 to enable PME
status for WOL.
Besides, the config1 (0x52) bit 0 is the read-only. Maybe you could skip setting
it.
 
Best Regards,
Hayes
