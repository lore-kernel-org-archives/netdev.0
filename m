From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [Bug 120441] af_packet no longer uses symmetric hashing
Date: Thu, 16 Jun 2016 16:37:52 +0200
Message-ID: <5762B9C0.9010902@iogearbox.net>
References: <511F6A17-BD35-4846-A717-1463B74D7F2A@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com, jiri@resnulli.us,
	willemb@google.com, eric@regit.org
To: Derek Ditch <derek.ditch@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56076 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754156AbcFPOh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 10:37:59 -0400
In-Reply-To: <511F6A17-BD35-4846-A717-1463B74D7F2A@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/16/2016 03:57 PM, Derek Ditch wrote:
[...]
>> Begin forwarded message:
>>
>> From: bugzilla-daemon@bugzilla.kernel.org
>> Subject: [Bug 120441] af_packet no longer uses symmetric hashing
>> Date: June 16, 2016 at 07:35:54 -0500
>> To: derek.ditch@gmail.com
>>
>> https://bugzilla.kernel.org/show_bug.cgi?id=120441

Just thinking out loud, perhaps one way would be to implement your own fanout
hashing via eBPF demuxer, f.e. in case CPU selection etc wouldn't work. Another
option could be to have a (2nd) customizable hash demux that would enforce to
always go through the flow-dissector and where you would have a socket option
to control keys for it, but I presume that seems rather less desirable.

>> --- Comment #2 from Eric Leblond <eric@regit.org> ---
>> This patch has been introduced in 4.2.
>>
>> --
>> You are receiving this mail because:
>> You reported the bug.
>> Begin forwarded message:
>>
>> From: bugzilla-daemon@bugzilla.kernel.org
>> Subject: [Bug 120441] af_packet no longer uses symmetric hashing
>> Date: June 16, 2016 at 06:59:58 -0500
>> To: derek.ditch@gmail.com
>>
>> https://bugzilla.kernel.org/show_bug.cgi?id=120441
>>
>> Eric Leblond <eric@regit.org> changed:
>>
>>            What    |Removed                     |Added
>> ----------------------------------------------------------------------------
>>                  CC|                            |eric@regit.org
>>
>> --- Comment #1 from Eric Leblond <eric@regit.org> ---
>> It seems the problem has been introduced by
>> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=42aecaa9bb2bd57eb8d61b4565cee5d3640863fb
>> where the symetrical jhash_3words function has been replaced by jhash2.
>>
>> --
>> You are receiving this mail because:
>> You reported the bug.
>
>
