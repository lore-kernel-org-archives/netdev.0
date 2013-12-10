From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next] net: ovs: use CRC32 accelerated flow hash if available
Date: Tue, 10 Dec 2013 13:36:22 -0800
Message-ID: <CAEP_g=-tKCnO=xWSHPj7aA7=E8ZxDAx=1OTfwqEqF3AAuKQenQ@mail.gmail.com>
References: <1386669178-14450-1-git-send-email-ffusco@redhat.com>
 <CAEP_g=_t750s50-F7A_hWD_yNs3MnKWN8WDBjzgoF8Mu+28Wyw@mail.gmail.com>
 <20131210.143652.1279430126319061689.davem@davemloft.net> <52A77DF4.5070302@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, ffusco@redhat.com,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: Thomas Graf <tgraf@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog115.obsmtp.com ([74.125.149.238]:33656 "HELO
	na3sys009aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751226Ab3LJVgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 16:36:43 -0500
Received: by mail-ie0-f174.google.com with SMTP id at1so9655451iec.33
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 13:36:42 -0800 (PST)
In-Reply-To: <52A77DF4.5070302@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 10, 2013 at 12:47 PM, Thomas Graf <tgraf@redhat.com> wrote:
> On 12/10/2013 08:36 PM, David Miller wrote:
>>
>> From: Jesse Gross <jesse@nicira.com>
>> Date: Tue, 10 Dec 2013 11:28:08 -0800
>>
>>> I think this is definitely a good optimization to do given that so
>>> much of the work that OVS does is hashing. However, isn't there a
>>> library where there would be a more appropriate place to put this?
>>
>>
>> I also honestly don't see why we want to special case OVS at all
>> here.  This faster hashing would be useful for socket demux and
>> other locations in the kernel.
>>
>> When I see changes like this my only reaction is "sad face".
>
>
> We discussed this heavily and decided to go with the minimal approach
> first to collect some feedback. We were not sure whether the runtime
> check, function pointer and hardware dependencies are something other
> subsystems that are less x86_64 centric would want to live with.
>
> That said, we are _very_ willing to do the work and move it to lib/
> to make it available to other consumers but one should be aware that
> crc32 based hashes are not as generally usable as jhash.

Most hash users probably don't care what the actual hash function is,
as long as it is consistent. Couldn't you have a function that uses
CRC32 if it is available (or whatever is appropriate on a given
architecture) and jhash otherwise? Most users would then be able to
call this function without knowing or caring about the various quirks.

We could also potentially use the static key stuff to get the right
hash function as well.
