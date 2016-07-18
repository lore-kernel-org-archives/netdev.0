From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/1] net_sched: Introduce skbmod action
Date: Mon, 18 Jul 2016 11:44:11 +0200
Message-ID: <578CA4EB.7060703@iogearbox.net>
References: <1468744884-8246-1-git-send-email-jhs@emojatatu.com> <20160718041933.GB36253@ast-mbp.thefacebook.com> <578C7C5C.2070804@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, nikolay@cumulusnetworks.com
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45783 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751725AbcGRJoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 05:44:21 -0400
In-Reply-To: <578C7C5C.2070804@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/18/2016 08:51 AM, Jamal Hadi Salim wrote:
> On 16-07-18 12:19 AM, Alexei Starovoitov wrote:
>> On Sun, Jul 17, 2016 at 04:41:24AM -0400, Jamal Hadi Salim wrote:
>>> From: Jamal Hadi Salim <jhs@mojatatu.com>
[...]
>> I can imagine new tc command 'action skbmod dmac 02:15:15:15:15:15' that
>> uses kernel pedit action undercover, so from user space point of view
>> the same effect can be achieved by extending iproute2.
>
> Of course - and i pointed to Cong it has been tried before. I should
> know because i wrote that code (just look at the pedit code in
> iproute2 for udp/icmp/ip type overlays).

Looking at that just out of curiosity on how complex it could look
for src/dst mac, is it actually functional in iproute2 upstream tree?

All I see is that pedit can look up 3rd party modules via get_pedit_kind(),
so it will pick p_%s.so, if built as such, and there's code for p_ip,
p_tcp, p_udp, p_icmp. But then, for example, all I see in p_udp.c is
since initial iproute2 import in 2005, apart from some cleanups by
Stephen:

static int
parse_udp(int *argc_p, char ***argv_p, struct tc_pedit_sel *sel, struct tc_pedit_key *tkey)
{
	int res = -1;
	return res;
}

struct m_pedit_util p_pedit_udp = {
	NULL,
	"udp",
	parse_udp,
};

Same for tcp, icmp, ipv6 bits code ... :/ Is it still planned to eventually
complete these? I agree that from a usability PoV, it might be nice to
have some kind of 'pretty printer' for it besides the existing config
parser there (e.g. when we know that a loaded instance was done with a
high-level module, we could annotate that for retrieval on dump or such).

Thanks,
Daniel
