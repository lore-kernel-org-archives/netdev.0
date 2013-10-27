From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: extending ndo_add_rx_vxlan_port
Date: Sun, 27 Oct 2013 22:34:50 +0200
Message-ID: <CAJZOPZ+S6ngqMjV-2ZMcpzkuWzzLWwCQMtd_1_SjDkqWh_tbYg@mail.gmail.com>
References: <526D2F8F.1070204@mellanox.com>
	<alpine.LFD.2.03.1310271017120.19783@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Yan Burman <yanb@mellanox.com>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Joseph Gasparakis <joseph.gasparakis@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:36545 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754605Ab3J0Uev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 16:34:51 -0400
Received: by mail-pd0-f169.google.com with SMTP id q10so6177816pdj.0
        for <netdev@vger.kernel.org>; Sun, 27 Oct 2013 13:34:50 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.03.1310271017120.19783@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 27, 2013 at 7:25 PM, Joseph Gasparakis
<joseph.gasparakis@intel.com> wrote:
>
>
> On Sun, 27 Oct 2013, Or Gerlitz wrote:
>
>> Hi,
>>
>> So with commit 53cf527513eed6e7170e9dceacd198f9267171b0 "vxlan: Notify drivers
>> for listening UDP port changes" drivers that have HW offloads for vxlan can be
>> notified on which UDP port to listen. Taking this further, some HW may need to
>> know the multicast address and/or the VNID used by the vxlan instance/s set
>> above them. In that respect, do we prefer to extend ndo_add_rx_vxlan_port() or
>> introduce new ndo?
>>
>> Or.
>>
>
> The way this patch works is to notify the drivers when a VXLAN UDP port
> comes up or down. This way drivers do not need to do any sort of accounting. As

Could you elaborate why do we want to notify all the netdev instances
in the system (on a certain name-space)
that vxlan instance/s are set to listen on certain UDP port and not
only the device over which the
vxlan device is being set? say the HW can listen limited amount of UDP
ports and few vxlan instances are created
one of top of each "real" netdev in the system and each on different
port. Each netdevice will get all callbacks on port addition
and at some point will start to fail adding them into the HW  when the
HW limit is met.

Or.
