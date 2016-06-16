From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [Bug 120441] af_packet no longer uses symmetric hashing
Date: Thu, 16 Jun 2016 17:18:20 +0200
Message-ID: <5762C33C.7030404@iogearbox.net>
References: <511F6A17-BD35-4846-A717-1463B74D7F2A@gmail.com> <5762B9C0.9010902@iogearbox.net> <40238392-1c86-53ce-7722-51dd5c2dc294@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com, jiri@resnulli.us,
	willemb@google.com, eric@regit.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Derek Ditch <derek.ditch@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60174 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754447AbcFPPSW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 11:18:22 -0400
In-Reply-To: <40238392-1c86-53ce-7722-51dd5c2dc294@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/16/2016 04:50 PM, Hannes Frederic Sowa wrote:
> On 16.06.2016 16:37, Daniel Borkmann wrote:
>> On 06/16/2016 03:57 PM, Derek Ditch wrote:
>> [...]
>>>> Begin forwarded message:
>>>>
>>>> From: bugzilla-daemon@bugzilla.kernel.org
>>>> Subject: [Bug 120441] af_packet no longer uses symmetric hashing
>>>> Date: June 16, 2016 at 07:35:54 -0500
>>>> To: derek.ditch@gmail.com
>>>>
>>>> https://bugzilla.kernel.org/show_bug.cgi?id=120441
>>
>> Just thinking out loud, perhaps one way would be to implement your own
>> fanout
>> hashing via eBPF demuxer, f.e. in case CPU selection etc wouldn't work.
>> Another
>> option could be to have a (2nd) customizable hash demux that would
>> enforce to
>> always go through the flow-dissector and where you would have a socket
>> option
>> to control keys for it, but I presume that seems rather less desirable.
>
> Isn't a symmetric hashing for af-packet something very fundamental?
> Looks much more like a bug to me.

I agree it would be useful resp. fundamental. I'm not quite sure whether
PACKET_FANOUT_HASH always had this guarantee since the initial implementation
f.e. depending on whether the skb got fanout demuxed from RX or TX paths,
you would either use a hw hash or it would have gone through the kernel's
(predecessor) flow dissector (and therefore potentially to different packet
sockets eventually). It might be the case that this got noticed due to the
flow dissector nowadays collecting more input for building its hash, hmm.

> Bye,
> Hannes
>
