From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next 1/5] vxlan: Make VXLAN default UDP port number
 available for others
Date: Tue, 11 Mar 2014 08:42:17 +0200
Message-ID: <CAJZOPZKBdZPuEe5uKLb3sw92q3Qko4RS-90uVAQK=+pFXVAfSA@mail.gmail.com>
References: <1394470142-13992-1-git-send-email-shahed.shaikh@qlogic.com>
	<1394470142-13992-2-git-send-email-shahed.shaikh@qlogic.com>
	<CAJZOPZ+MFe2ev372L07uVvXs_wYnqAiZ3VMG4YteD2XmPWHoSQ@mail.gmail.com>
	<262CB373A6D1F14F9B81E82F74F77D5A46F797EE@avmb2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dept-HSG Linux NIC Dev <Dept-HSGLinuxNICDev@qlogic.com>
To: Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:45763 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752279AbaCKGmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 02:42:18 -0400
Received: by mail-pd0-f173.google.com with SMTP id z10so8137995pdj.32
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 23:42:17 -0700 (PDT)
In-Reply-To: <262CB373A6D1F14F9B81E82F74F77D5A46F797EE@avmb2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 11, 2014 at 7:41 AM, Shahed Shaikh <shahed.shaikh@qlogic.com> wrote:
>> -----Original Message-----
>> From: Or Gerlitz [mailto:or.gerlitz@gmail.com]
>> Sent: Tuesday, March 11, 2014 1:28 AM
>> To: Shahed Shaikh
>> Cc: David Miller; netdev; Dept-HSG Linux NIC Dev
>> Subject: Re: [PATCH net-next 1/5] vxlan: Make VXLAN default UDP port
>> number available for others
>>
>> On Mon, Mar 10, 2014 at 6:48 PM, Shahed Shaikh
>> <shahed.shaikh@qlogic.com> wrote:
>> > From: Shahed Shaikh <shahed.shaikh@qlogic.com>
>> >
>> > Although vxlan module has capability to notify udp ports to other
>> > interested net devices using .ndo_add_rx_vxlan_port and
>> > .ndo_del_rx_vxlan_port, there could be some devices which support
>> > vxlan offload but not interested in updating udp port numbers.
>> > This may be because some hardware do not support programming multiple
>> > udp ports and their drivers may decide to program only default udp
>> > port into adapter. So that adapter, at least, can do offloading for
>> > default udp port number.
>>
>> Indeed, but the default port number can be unused while another port is
>> used. The ndo will be invoked only behalf of an actual instancing of udp port
>> for listener socket (== destination port you want the hw to indentify), what's
>> wrong with support this ndo also for devices that supported limited (say
>> one) such port?
>
>
>  If driver implements .ndo for udp port and user creates multiple vxlan device with different
> udp ports, it may end up programming the udp port which may not go through the adapter
> and no offload will happen. OTOH, if drive does not implement .ndo and if user is aware that driver
>  is capable of offloading for default port, he can at least crate vxlan device on top of qlcnic interface
>  with default udp port. So, there is no chance for other udp port numbers to replace default udp port and disturb offloading.

I see your point, but doesn't this suggests we need to somehow enhance
 the current framework to
let drivers know which vxlan traffic is expected to be received over
them according to the current routing rules?
I understand this is a bit tricky because  vxlan and routing  are l3
constructs while drivers deal with l2, John/Joseph -
what's your thinking here?


> Like Stephen suggested, exporting udp port variable of vxlan driver will be more suitable approach.
