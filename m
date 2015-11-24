From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Mon, 23 Nov 2015 16:38:59 -0800
Message-ID: <CALx6S36H4eyDg-Vv21X2GaGA+g=KfN6iHX=8uM2isEOnPTjs0Q@mail.gmail.com>
References: <1448312579-159544-1-git-send-email-anjali.singhai@intel.com>
	<1448312579-159544-2-git-send-email-anjali.singhai@intel.com>
	<CALx6S34+_AtjO94znh7vW4py5a8Nj1g6b-sjGPCa4U1Mc6Y6-w@mail.gmail.com>
	<CAEh+42jWN961Gg59xbdXiFj9u7=3vuFdyXkcr6iPJ92ZizPpGw@mail.gmail.com>
	<C40BE8378EF49C44B9184714DBC8EF29939A13AA@ORSMSX115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"Patil, Kiran" <kiran.patil@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: "Singhai, Anjali" <anjali.singhai@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:33610 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752335AbbKXAjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 19:39:00 -0500
Received: by iouu10 with SMTP id u10so4811015iou.0
        for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 16:39:00 -0800 (PST)
In-Reply-To: <C40BE8378EF49C44B9184714DBC8EF29939A13AA@ORSMSX115.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 23, 2015 at 4:32 PM, Singhai, Anjali
<anjali.singhai@intel.com> wrote:
>
>
>> -----Original Message-----
>> From: Jesse Gross [mailto:jesse@kernel.org]
>> Sent: Monday, November 23, 2015 2:50 PM
>> To: Tom Herbert
>> Cc: Singhai, Anjali; Linux Kernel Network Developers; Patil, Kiran
>> Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
>>
>> On Mon, Nov 23, 2015 at 1:53 PM, Tom Herbert <tom@herbertland.com>
>> wrote:
>> >> diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
>> >> index cb2f89f..72415aa 100644
>> >> --- a/include/net/udp_tunnel.h
>> >> +++ b/include/net/udp_tunnel.h
>> >> @@ -9,6 +9,12 @@
>> >>  #include <net/addrconf.h>
>> >>  #endif
>> >>
>> >> +enum udp_tunnel_type {
>> >> +       UDP_TUNNEL_UNSPEC,
>> >> +       UDP_TUNNEL_VXLAN,
>> >> +       UDP_TUNNEL_GENEVE,
>> >> +};
>> >> +
>> >
>> > Sorry, I still don't like this. Grant it least it gets rid of of VXLAN
>> > specific ops, but the problem is there no such things as a common set
>> > of encapsulations in the kernel (e.g. foo-over-udp adds a bunch of
>> > encapsulations not represented here), no defined common set of device
>> > functionality that needs this, and this precludes the use of the RX
>> > accelerations to be available from a userpsace  implementation.
>>
>> Regardless, I think this is at least a good cleanup of what is already
>> there compared to having VXLAN-specific NDOs. We can always add
>> additional things in the future.
>
> Agreed with Jesse that this will help not hurt,  when we are ready to cross the bridge for removing RX side Protocol ossification.
>
The time is now to address the protocol ossification problem. HW
vendors leaking out support for random protocols one at a time really
isn't helpful at all. Unfortunately, it's pretty clear that many
vendors aren't going to fix this on their own volition. Fixing the
interfaces to "encourage" change seems to be a way we can help things
a long from kernel perspective.

Tom
