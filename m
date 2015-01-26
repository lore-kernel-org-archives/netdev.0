From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: Question on SCTP ABORT chunk is generated when the association_max_retrans
 is reached
Date: Mon, 26 Jan 2015 09:46:26 -0200
Message-ID: <54C62912.3040401@gmail.com>
References: <CAFXGftKp3=OfjkCVBuR-zM3+uZ42Sk_9i2UjAHBNnbX=hQJwpA@mail.gmail.com>	<CAFXGft+fwo=8LJEG7h6uOpGciSo5f_dXjSx3sn67RZZp7jsYHw@mail.gmail.com>	<54C23581.9060809@redhat.com>	<54C27137.5010405@gmail.com>	<54C2807E.8080607@redhat.com>	<8BBFBEE6-FA34-4190-BFCB-AB6BEC093774@fh-muenster.de>	<54C29B82.7090502@redhat.com> <CAFXGft+XZCmhuwj2QTCiU0MD10Uo+WZ3WCC+rfbsd_Lxbhk3iw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Tuexen <tuexen@fh-muenster.de>,
	Vlad Yasevich <vyasevich@gmail.com>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sun Paul <paulrbk@gmail.com>, Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFXGft+XZCmhuwj2QTCiU0MD10Uo+WZ3WCC+rfbsd_Lxbhk3iw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 25-01-2015 23:27, Sun Paul wrote:
> Hi
>
> sorry for the late reply. I am a bit confused. when side-A sends a
> request to side-B, and side-B return the response, but side-A keep
> re-transmit the same request to side-B, why side-B needed to send a
> ABORT to side-A?

That happens on data transfers. When A pushes data to B, A has to retry it 
until B finally acknowledges it and A receive this signal. If the ack from B 
gets dropped, A has no way to know if a) the ack was lost or b) its initial 
message never actually made it to A, thus it retransmits. If it reaches a 
limit, it gives up..

> If it is used in order to reestablish the connection, shoudn't it
> should be side-A to send ABORT instead?

Meant to reestablish it? Not really.. just to keep both sides in sync, as A 
has given up by then.

   Marcelo

> - PS
>
> On Sat, Jan 24, 2015 at 3:05 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> On 01/23/2015 07:36 PM, Michael Tuexen wrote:
>> ...
>>>
>>> Yepp. It might not reach the peer or it might. If it does it helps
>>> to keep the states in sync. If it doesn't it sometimes helps in
>>> analysing tracefiles. In BSD, we also send it. It is not required,
>>> doesn't harm and is useful in some cases...
>>
>>
>> Ok, as the TCB is destroyed in any case, should be fine then.
>>
>> Thanks,
>> Daniel
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
