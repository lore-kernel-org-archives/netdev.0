From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: Re: TCP_MAXSEG option with TSO enabled
Date: Fri, 30 Mar 2012 21:07:57 +0300
Message-ID: <CAEnQRZB4sGP=6-Z_8G3P-BVo+wE_tbCdFUnTEgADd11XXBa6xw@mail.gmail.com>
References: <CAEnQRZC1sLW8BUOx2ov-S-UUSyfAi7Wem2mAzUHBHn2o9q-eRg@mail.gmail.com>
	<4F75EF78.4060402@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:45784 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752141Ab2C3SH6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2012 14:07:58 -0400
Received: by vbbff1 with SMTP id ff1so555288vbb.19
        for <netdev@vger.kernel.org>; Fri, 30 Mar 2012 11:07:57 -0700 (PDT)
In-Reply-To: <4F75EF78.4060402@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 30, 2012 at 8:38 PM, Rick Jones <rick.jones2@hp.com> wrote:
> On 03/30/2012 04:33 AM, Daniel Baluta wrote:
>>
>> Hello,
>>
>> I am using TCP_MAXSEG option on an interface which has TSO enabled.
>>
>> strace output for connection looks as follows:
>>
>> socket(PF_INET, SOCK_STREAM, IPPROTO_IP) =3D 26
>> setsockopt(26, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
>> setsockopt(26, SOL_TCP, TCP_NODELAY, [1], 4) =3D 0
>> setsockopt(26, SOL_TCP, TCP_MAXSEG, [300], 4) =3D 0
>> connect(26, {sa_family=3DAF_INET, sin_port=3Dhtons(1935),
>> sin_addr=3Dinet_addr("10.10.0.1")}, 16) =3D -1 EINPROGRESS (Operatio=
n now
>> in progress)
>>
>> I can see that MSS (300) is advertised in SYN packet, anyhow capturi=
ng
>> the traffic
>> I notice that are some TCP segments with length greater than MSS.
>>
>> Is this normal taking in consideration that TSO is enabled?
>
>
> I would think so. =A0What do the netstat stats suggest for segments a=
nd bytes
> per segment when you are running your test? =A0You could always look =
for an
> on-the-wire packet trace.
>
> Not sure that a trace on a receiver would give you that though - the =
inbound
> promiscuous tap may be above GRO (and almost certainly will be above =
LRO)

Thanks Rick. Indeed on-the-wire capture looks fine. I have TSO enabled
at sender and LRO at receiver, everything makes sense now.

thanks,
Daniel.
