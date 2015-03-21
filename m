From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v2] filter: introduce SKF_AD_VLAN_TPID BPF extension
Date: Sat, 21 Mar 2015 10:49:51 +0100
Message-ID: <550D3EBF.4000907@iogearbox.net>
References: <1426763414-10091-1-git-send-email-msekleta@redhat.com> <550AF483.8040202@plumgrid.com> <20150320102718.GB30812@morgoth.brq.redhat.com> <550CD62C.7080105@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Russell King <linux@arm.linux.org.uk>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Alexei Starovoitov <ast@plumgrid.com>,
	Michal Sekletar <msekleta@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42262 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751229AbbCUJuC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 05:50:02 -0400
In-Reply-To: <550CD62C.7080105@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/21/2015 03:23 AM, Alexei Starovoitov wrote:
> On 3/20/15 3:27 AM, Michal Sekletar wrote:
>> On Thu, Mar 19, 2015 at 09:08:35AM -0700, Alexei Starovoitov wrote:
>>> Since it's a new field, I think it makes sense not to do ntohs at all.
>>> Let bpf programs do htons(PROTO_CONSTANT), since it can be done at
>>> compile time instead of run-time.
>>
>> Doing htons is not needed for vlan_tci thus I wanted to avoid surprise for
>> users. But of course I'll do whatever you think is the best.
>
> ok. then let's not add ntohs for vlan_tpid

Why? What speaks against handling this the exact same way as we
do now with skb->protocol?

>> Also in v3 I will leave out all the jit bits. Once non-jit bits are merged then
>> I will be sending separate patches for the rest.
>
> agree. makes sense to do classic JITs later as separate patch(es).

+1

> Could you also then add it to extended BPF as part of the same patch?
> Same code should cover both classic and extended.
> imo SKF_AD_VLAN_TPID is good as name for classic and
> 'vlan_tpid' as new field name for extended.
>
> Thanks
