From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH v6 net-next 0/2] tcp: Redundant Data Bundling (RDB)
Date: Wed, 9 Mar 2016 18:27:09 -0800
Message-ID: <CAK6E8=eq3NGJDwreh6UL2hAHXEiPbRZPbXe2pc5aUPBgNoWtGA@mail.gmail.com>
References: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
 <1457028388-18226-1-git-send-email-bro.devel+kernel@gmail.com>
 <CAK6E8=eKu_0ReSDLYdyajxMyX2MaN=wDLHvq=u_tyNnMRS31sw@mail.gmail.com> <78983A17-6B0C-4A11-BE0E-A98FE699D1E3@ifi.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Bendik_R=C3=B8nning_Opstad?= <bro.devel@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Neal Cardwell <ncardwell@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	=?UTF-8?Q?P=C3=A5l_Halvorsen?= <paalh@simula.no>,
	Kristian Evensen <kristian.evensen@gmail.com>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: Jonas Markussen <jonassm@ifi.uio.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:33494 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752971AbcCJC1v convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 21:27:51 -0500
Received: by mail-wm0-f43.google.com with SMTP id l68so10274699wml.0
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 18:27:50 -0800 (PST)
In-Reply-To: <78983A17-6B0C-4A11-BE0E-A98FE699D1E3@ifi.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 9, 2016 at 5:45 PM, Jonas Markussen <jonassm@ifi.uio.no> wr=
ote:
>
>> On 10 Mar 2016, at 01:20, Yuchung Cheng <ycheng@google.com> wrote:
>>
>> PS. I don't understand how (old) RDB can masquerade the losses by
>> skipping DUPACKs. Perhaps an example helps. Suppose we send 4 packet=
s
>> and the last 3 were (s)acked. We perform RDB to send a packet that h=
as
>> previous 4 payloads + 1 new byte. The sender still gets the loss
>> information?
>>
>
> If I=E2=80=99ve understood you correctly, you=E2=80=99re talking abou=
t sending 4
> packets and the first one is lost?
>
> In this case, RDB will not only bundle on the last/new packet but als=
o
> as it sends packet 2 (which will contain 1+2), packet 3 (1+2+3)
> and packet 4 (1+2+3+4).
>
> So the fact that packet 1 was lost is masqueraded when it is
> recovered by packet 2 and there won=E2=80=99t be any gap in the SACK =
window
> indicating that packet 1 was lost.
I see. Thanks for the clarification.

So my question is still if thin-stream app has enough inflight to use
ack-triggered recovery. i.e., it has to send at least twice within an
RTT.

Also have you tested this with non-Linux receivers? Thanks.

>
> Best regards,
> Jonas Markussen
