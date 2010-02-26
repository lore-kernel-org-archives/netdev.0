From: "richardvoigt@gmail.com" <richardvoigt@gmail.com>
Subject: Re: [Bridge] [RFC 0/5] bridge - introduce via_phys_dev feature
Date: Fri, 26 Feb 2010 10:52:52 -0600
Message-ID: <2e59e6971002260852m79d9c79t5293b3b8c7575d46@mail.gmail.com>
References: <20090511114639.440944109@openvz.org>
	 <20090519152153.012d4814@nehalam> <20090520192726.GF4968@lenovo>
	 <20090520131225.03b7715a@nehalam> <20090521180805.GC4932@lenovo>
	 <20090521140504.1865883b@nehalam> <20090522201850.GF5354@lenovo>
	 <20100226081843.07f37742@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, netdev@vger.kernel.org,
	bridge@linux-foundation.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f219.google.com ([209.85.220.219]:57967 "EHLO
	mail-fx0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965375Ab0BZQwx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 11:52:53 -0500
Received: by fxm19 with SMTP id 19so291695fxm.21
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2010 08:52:52 -0800 (PST)
In-Reply-To: <20100226081843.07f37742@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 26, 2010 at 10:18 AM, Stephen Hemminger
<shemminger@linux-foundation.org> wrote:
> Looking back at this. What if the API was simpler:
>
> Instead of:
>> Typical session looks like
>>
>> | s...@10.10.0.160$ brctl addbr br0
>> | s...@10.10.0.160$ ifconfig br0 up
>> | s...@10.10.0.160$ echo 1 > /sys/class/net/bridge/br0/via_phys_dev
>> | s...@10.10.0.160$ brctl addif br0 eth0
>> | (...waiting a bit...)
>> | s...@10.10.0.160$
>
> Why not:
> =C2=A01. Setup bridge (and any other interfaces except eth0); include=
s bringing br0 up
> =C2=A02. Add eth0 to bridge with new flag to inherit
> =C2=A0 =C2=A0 =C2=A0 a. brctl addif br0 eth0 inherit
>
> Inherit functionality would need to move address (Ether, IP, IPv6)
> and routes from eth0 to br0.
> I will see about doing it as much as possible in userspace.

How about inheriting the up/down status as well, this way the bridge
can be left down until the settings are inherited, and will come up
with the inherited MAC address, IP address, and routing table instead
of changing while live?

> _______________________________________________
> Bridge mailing list
> Bridge@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/bridge
>
