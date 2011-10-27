From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: Re: [PATCH] Add TCP_NO_DELAYED_ACK socket option
Date: Thu, 27 Oct 2011 14:54:32 +0300
Message-ID: <CAEnQRZAmDMg943uufpwf4dj0vw9hfsRu3RFRG+LEqfT2Y0ty1Q@mail.gmail.com>
References: <fc8b00b9978b4f956fa705badfaa138854abf919.1319595687.git.luto@amacapital.net>
	<1319711072.2601.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Lutomirski <luto@amacapital.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:53347 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754294Ab1J0Lyd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 07:54:33 -0400
Received: by qyk27 with SMTP id 27so3024293qyk.19
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2011 04:54:32 -0700 (PDT)
In-Reply-To: <1319711072.2601.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 27, 2011 at 1:24 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mardi 25 octobre 2011 =E0 19:25 -0700, Andy Lutomirski a =E9crit :
>> When talking to an unfixable interactive peer that fails to set
>> TCP_NODELAY, disabling delayed ACKs can help mitigate the problem.
>> This is an evil thing to do, but if the entire network is private,
>> it's not that evil.
>>
>> This works around a problem with the remote *application*, so make
>> it a socket option instead of a sysctl or a per-route option.
>>
>> Signed-off-by: Andy Lutomirski <luto@amacapital.net>
>> ---
>>
>> This patch is a bit embarrassing. =A0We talk to remote applications =
over
>> TCP that are very much interactive but don't set TCP_NODELAY. =A0The=
se
>> applications apparently cannot be fixed. =A0As a partial workaround,=
 if we
>> ACK every incoming segment, then as long as they don't transmit two
>> segments per rtt, we do pretty well.
>>
>> Windows can do something similar, but it's per interface instead of =
per
>> socket:
>>
>> http://support.microsoft.com/kb/328890
>
> Hi Andy
>
> Yet another delayed ack hacking proposal :)
>
> Well, to be honest, I find the MS Windows tunable more generic.
> [ But doing it for a whole interface is wrong, it should be per socke=
t
> to allow best tuning ]
>
> Setting the value to 4 (instead of default 2) for example would _redu=
ce_
> number of ACK packets in bulk transferts [ We can do that if GRO is o=
n,
> as a side effect ]
>
> Also the 40ms/200ms values (TCP_DELACK_{MIN|MAX}) could be tunables.
> (system or per socket)
> RFC 1122 says it SHOULD be less than 500ms. The time criteria is IMHO
> far more palatable for an application author than "number of delayed
> acks"

Hello Eric,

=46ew days ago, in our custom kernel we made TCP Delack segments and
TCP Delack timeout parameters tunable via proc entries.
Increasing tcp_delack_segs (number of full sized segments that must
be received until an ACK is sent) we observed an improvement of
throughput up to 20% in some test cases.

Do you think that this kind of patch would have a chance to be
included in mainstream?

thanks,
Daniel.
