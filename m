From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH v6] sctp: be more restrictive in transport selection on bundled sacks
Date: Sat, 30 Jun 2012 23:17:52 -0400
Message-ID: <a1fb36e6-783a-4a89-9771-a7010c2da4fb@email.android.com>
References: <1340742704-2192-1-git-send-email-nhorman@tuxdriver.com> <1341061466-4186-1-git-send-email-nhorman@tuxdriver.com> <20120630.173945.173993639982489712.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: David Miller <davem@davemloft.net>, nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:33897 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754737Ab2GADR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2012 23:17:57 -0400
In-Reply-To: <20120630.173945.173993639982489712.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:

>From: Neil Horman <nhorman@tuxdriver.com>
>Date: Sat, 30 Jun 2012 09:04:26 -0400
>
>> It was noticed recently that when we send data on a transport, its
>possible that
>> we might bundle a sack that arrived on a different transport.  While
>this isn't
>> a major problem, it does go against the SHOULDAcm requirement in section
>6.4 of RFC
>> 2960:
>> 
>>  An endpoint SHOULD transmit reply chunks (e.g., SACK, HEARTBEAT ACK,
>>    etc.) to the same destination transport address from which it
>>    received the DATA or control chunk to which it is replying.  This
>>    rule should also be followed if the endpoint is bundling DATA
>chunks
>>    together with the reply chunk.
>> 
>> This patch seeks to correct that.  It restricts the bundling of sack
>operations
>> to only those transports which have moved the ctsn of the association
>forward
>> since the last sack.  By doing this we guarantee that we only bundle
>outbound
>> saks on a transport that has received a chunk since the last sack. 
>This brings
>> us into stricter compliance with the RFC.
>> 
>> Vlad had initially suggested that we strictly allow only sack
>bundling on the
>> transport that last moved the ctsn forward.  While this makes sense,
>I was
>> concerned that doing so prevented us from bundling in the case where
>we had
>> received chunks that moved the ctsn on multiple transports.  In those
>cases, the
>> RFC allows us to select any of the transports having received chunks
>to bundle
>> the sack on.  so I've modified the approach to allow for that, by
>adding a state
>> variable to each transport that tracks weather it has moved the ctsn
>since the
>> last sack.  This I think keeps our behavior (and performance), close
>enough to
>> our current profile that I think we can do this without a sysctl knob
>to
>> enable/disable it.
>> 
>> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>> CC: Vlad Yaseivch <vyasevich@gmail.com>
>> CC: David S. Miller <davem@davemloft.net>
>> CC: linux-sctp@vger.kernel.org
>> Reported-by: Michele Baldessari <michele@redhat.com>
>> Reported-by: sorin serban <sserban@redhat.com>
>
>Once this has Vlad's ACK I'll apply it.
>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

Sorry for the delay.

-vlad

>There has to be a better way to handle this situation, wherein the
>responsible party has ACK'd the patch but I just ask for a few coding
>style fixups and whatnot.  As it stands now I have to twiddle my
>thumbs waiting for the new ACK.


-- 
Sent from my Android phone with SkitMail. Please excuse my brevity.
