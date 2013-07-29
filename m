From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v4 1/7] vxlan: Add vxlan_handler.
Date: Mon, 29 Jul 2013 13:17:42 -0700
Message-ID: <CALnjE+rexP5B5Ofqwbtj_bmj-gABHORmV-DyoceGi7XV90d=EA@mail.gmail.com>
References: <1374880488-2884-1-git-send-email-pshelar@nicira.com>
	<20130726165220.1106ac41@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog120.obsmtp.com ([74.125.149.140]:42617 "HELO
	na3sys009aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754318Ab3G2URn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 16:17:43 -0400
Received: by mail-qc0-f171.google.com with SMTP id n1so3110747qcw.16
        for <netdev@vger.kernel.org>; Mon, 29 Jul 2013 13:17:42 -0700 (PDT)
In-Reply-To: <20130726165220.1106ac41@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 26, 2013 at 4:52 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Fri, 26 Jul 2013 16:14:48 -0700
> Pravin B Shelar <pshelar@nicira.com> wrote:
>
>> vxlan and openvswitch modules needs to share port. Following
>> patch breaks down vxlan per port abstraction in two component.
>> So now vxlan_sock is broken into struct vxlan_sock handles socket
>> and vxlan_handler which handler for user of vxlan protocol.
>>
>> Next commit will extend vxlan_handler for openvswitch.
>>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>
> Not sure why the added complexity here is needed.
>
> Since the are separate services, why not run them on separate
> UDP ports. Otherwise unless the kernel and the Openvswitch
> controller share state (which would be really hard given that
> OVS controller is in user space), the chance of overlapping
> configuration seems like a trap.
>
> There is already a lot of layering in VXLAN between the
> device, forwarding table, VNI, and multiple UDP sockets.
> Doing this needs more thought or persuasive use cases.

I agree sharing state between kernel-vxlan and ovs-vxlan does not
makes much sense. I will rework patches without vxlan-udp-port sharing
which will eliminate that possibility entirely.
