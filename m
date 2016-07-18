From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 1/1] net_sched: Introduce skbmod action
Date: Mon, 18 Jul 2016 06:08:22 -0400
Message-ID: <578CAA96.2090501@mojatatu.com>
References: <1468744884-8246-1-git-send-email-jhs@emojatatu.com>
 <20160718041933.GB36253@ast-mbp.thefacebook.com>
 <578C7C5C.2070804@mojatatu.com> <578CA4EB.7060703@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, nikolay@cumulusnetworks.com
To: Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:35670 "EHLO
	mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752013AbcGRKIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 06:08:30 -0400
Received: by mail-qk0-f175.google.com with SMTP id s63so152440045qkb.2
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 03:08:29 -0700 (PDT)
In-Reply-To: <578CA4EB.7060703@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-07-18 05:44 AM, Daniel Borkmann wrote:
> On 07/18/2016 08:51 AM, Jamal Hadi Salim wrote:
>> On 16-07-18 12:19 AM, Alexei Starovoitov wrote:

> Looking at that just out of curiosity on how complex it could look
> for src/dst mac, is it actually functional in iproute2 upstream tree?
>

No it is a bunch of bash script wrapping we did on top of pedit (which
should be no different than adding it to m_pedit as an extension).
We started there then decided that this feature is mostly used with
mirred all the time - so modified  mirred.

> All I see is that pedit can look up 3rd party modules via get_pedit_kind(),
> so it will pick p_%s.so, if built as such, and there's code for p_ip,
> p_tcp, p_udp, p_icmp. But then, for example, all I see in p_udp.c is
> since initial iproute2 import in 2005, apart from some cleanups by
> Stephen:
>

Yes, IP and tcp should be fine. Others were place holders.
Note, there is even no need to change pedit - you could write a bash
script as we did.

> static int
> parse_udp(int *argc_p, char ***argv_p, struct tc_pedit_sel *sel, struct
> tc_pedit_key *tkey)
> {
>      int res = -1;
>      return res;
> }
>
> struct m_pedit_util p_pedit_udp = {
>      NULL,
>      "udp",
>      parse_udp,
> };
>
> Same for tcp, icmp, ipv6 bits code ... :/ Is it still planned to eventually
> complete these?

someone else could run with it; at the moment i think this was ok at
small scale but it hasnt worked well in a larger scale. When you write
other apps (other than tc) to use these APIs parsing all the 32 bit
chunks is more cumbersome then getting a struct which gives me precise
info.

I agree that from a usability PoV, it might be nice to
> have some kind of 'pretty printer' for it besides the existing config
> parser there (e.g. when we know that a loaded instance was done with a
> high-level module, we could annotate that for retrieval on dump or such).
>

If i could tag the structure with something the kernel then returns to
me when i dump, I could add nice pretty printers (same arguement applies
to u32).
But that doesnt solve the programmability issue as being a good cause.

cheers,
jamal
