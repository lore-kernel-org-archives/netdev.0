From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP Connection teardown seems to violate TCP specification
Date: Wed, 14 Aug 2013 13:14:23 -0700
Message-ID: <520BE51F.40208@hp.com>
References: <1376508095.4596.12.camel@nexus> <CAK6E8=fWOe3eEvw6sC=Da415qGp+wXsm2bpe9Vbbukit9yU8sQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Damian Lukowski <damian@tvk.rwth-aachen.de>,
	netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:8442 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933081Ab3HNUOZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 16:14:25 -0400
In-Reply-To: <CAK6E8=fWOe3eEvw6sC=Da415qGp+wXsm2bpe9Vbbukit9yU8sQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/14/2013 12:50 PM, Yuchung Cheng wrote:
> On Wed, Aug 14, 2013 at 12:21 PM, Damian Lukowski
> <damian@tvk.rwth-aachen.de> wrote:
>> Hi,
>>
>> the TCP specification states that an endpoint has to accept
>> packets from the other side even after it has half-closed the
>> connection locally. This does not seem to be the case
>> under Linux?
>>
>> For example, when I wget -O /dev/null https://www.verisign.com/
>> --max-redir 0, the local TCP stack sends an FIN,ACK close to the end.
>> However, the webserver has more data to send (Encrypted Alert).
>> Instead of ACKing the packet, the local side sends a RST.
>> This seems wrong to me.
>
> Which wget are you using? it's not doing half-close (i.e.,
> shutdown(SHUT_WR)) on my wget version 1.13.4

I suspect that when Damian system call traces his wget he will find it 
is doing either:

close()

or
shutdown(SHUT_WR)
close()
without waiting for the read return of zero from the remote.

it may even be just exiting after getting the last bytes of the URL, 
which would be an implicit close()

Over the years I've seen examples of all three behaviours.

rick jones

>
>
>>
>> Regards
>>   Damian
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
