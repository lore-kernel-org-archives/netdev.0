From: Gaspar Chilingarov <gasparch@gmail.com>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge amount
	of outgoing connections (unable to bind ... )
Date: Wed, 21 Apr 2010 04:57:42 +0500
Message-ID: <n2g46c8cb3e1004201657t50599d7em5535f2f12af96b59@mail.gmail.com>
References: <g2z46c8cb3e1004201517i5641a75cze2ec5bd33e81fb0f@mail.gmail.com>
	 <4BCE33B9.8050101@candelatech.com>
	 <u2t46c8cb3e1004201620tf9fce087ibae421759f9e1e84@mail.gmail.com>
	 <4BCE392F.60104@candelatech.com>
	 <y2p46c8cb3e1004201635s8f84672dq90d3115dca04a1ed@mail.gmail.com>
	 <4BCE3D8D.3030500@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:54067 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751999Ab0DTX5o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 19:57:44 -0400
Received: by bwz25 with SMTP id 25so7459518bwz.28
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 16:57:42 -0700 (PDT)
In-Reply-To: <4BCE3D8D.3030500@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ohhh, see my bug report again, please :)

The problem arises when used port count is close to or more than the
number of local ports available on the system (in your case 40000
client connections is smaller than 51000 of available ports).

I think that if you choose to go with default settings and try to bind
half of your ports to one local IP and half of your ports - to another
one -- you will hit this bug as well.

If you explicitly bind to the local ports as well - it _may_ solve a
problem - I will this today (it's just a workaround, but in fact not
the solution :), but if you let kernel automatically find local ports
- you will get the errors.

/Gaspar


2010/4/21 Ben Greear <greearb@candelatech.com>:
> On 04/20/2010 04:35 PM, Gaspar Chilingarov wrote:
>>
>> sysctl -a | grep local_port_range
>
> [root@ct503-10G-09 ~]# sysctl -a | grep local_port_range
> net.ipv4.ip_local_port_range =3D 10000 =C2=A0 =C2=A061000
>
> I'm explicitly binding to local ports as well as local IPs, btw.
>
> Thanks,
> Ben
>
> --
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc =C2=A0http://www.candelatech.com
>



--=20
Gaspar Chilingarov
