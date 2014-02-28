From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] ixgbevf: fix skb->pkt_type checks
Date: Fri, 28 Feb 2014 15:31:16 -0800
Message-ID: <CAGVrzcapY4nsvi+MenKDjnvR7be2iBH1BquQERjuwVJW3VAyVQ@mail.gmail.com>
References: <1393454640-19651-1-git-send-email-f.fainelli@gmail.com>
 <1393541926.1931.4.camel@localhost> <309B89C4C689E141A5FF6A0C5FB2118B73162EDE@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Brown, Aaron F" <aaron.f.brown@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:57319 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734AbaB1Xb5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 18:31:57 -0500
Received: by mail-pb0-f43.google.com with SMTP id um1so1388029pbc.16
        for <netdev@vger.kernel.org>; Fri, 28 Feb 2014 15:31:57 -0800 (PST)
In-Reply-To: <309B89C4C689E141A5FF6A0C5FB2118B73162EDE@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-02-28 15:26 GMT-08:00 Brown, Aaron F <aaron.f.brown@intel.com>:
> On Thu, 2014-02-27 at 14:58 -0800, Aaron Brown wrote:
>> On Wed, 2014-02-26 at 14:44 -0800, Florian Fainelli wrote:
>> > skb->pkt_type is not a bitmask, but contains only value at a time =
from
>> > the range defined in include/uapi/linux/if_packet.h.
>> >
>> > Checking it like if it was a bitmask of values would also cause
>> > PACKET_OTHERHOST, PACKET_LOOPBACK and PACKET_FASTROUTE to be match=
ed by this
>> > check since their lower 2 bits are also set, although that does no=
t fix a real
>> > bug due to how the checks are used, it is still potentially confus=
ing.
>> >
>> > This bogus check was introduced in commit 815cccbf ("ixgbe: add se=
tlink,
>> > getlink support to ixgbe and ixgbevf").
>> >
>> > Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> > ---
>> >  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 5 +++--
>> >  1 file changed, 3 insertions(+), 2 deletions(-)
>>
>> Thanks Florian, I have added this to our internal queue.
>
> Unfortunately this introduces a compile error:
> ----------------------------------------------
> /usr/src/kbuild_net-next_community/arch/x86/Makefile:133: CONFIG_X86_=
X32
> enabled but no binutils support
> drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c: In function
> =E2=80=98ixgbevf_clean_rx_irq=E2=80=99:
> drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c:521: error: =E2=80=98=
adapter=E2=80=99
> undeclared (first use in this function)
> drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c:521: error: (Each
> undeclared identifier is reported only once
> drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c:521: error: for eac=
h
> function it appears in.)
> make[5]: *** [drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.o] Erro=
r 1
> make[5]: *** Waiting for unfinished jobs....
> make[4]: *** [drivers/net/ethernet/intel/ixgbevf] Error 2
> make[3]: *** [drivers/net/ethernet/intel] Error 2
> make[3]: *** Waiting for unfinished jobs....
> make[2]: *** [drivers/net/ethernet] Error 2
> make[1]: *** [drivers/net] Error 2
> make: *** [drivers] Error 2
> ~
> ----------------------------------------------
> Are willing to fix up a v2?

Sure, let me re-submit with a fixed version (seems like I rebased
against an earlier version).
--=20
=46lorian
