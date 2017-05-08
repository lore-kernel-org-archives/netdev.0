From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: bpf pointer alignment validation
Date: Mon, 08 May 2017 12:49:25 +0200
Message-ID: <59104D35.8080108@iogearbox.net>
References: <20170505.162044.2097924822206705957.davem@davemloft.net> <20170505.224709.1156323937148435706.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43769 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754211AbdEHKti (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 06:49:38 -0400
In-Reply-To: <20170505.224709.1156323937148435706.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/06/2017 04:47 AM, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Fri, 05 May 2017 16:20:44 -0400 (EDT)
>
>> Anyways, I'll play with this design and see what happens...
>> Feedback is of course welcome.
>
> Here is a prototype that works for me with test_pkt_access.c,
> which otherwise won't load on sparc.

Code looks good to me as far as I can tell, thanks for working
on this.

Could you also add test cases specifically to this for test_verifier
in bpf selftests? I'm thinking of the cases when we have no pkt id
and offset originated from reg->off (accumulated through const imm
ops on reg) and insn->off, where we had i) no pkt id and ii) a
specific pkt id (so we can probe for aux_off_align rejection as well).
I believe we do have coverage to some extend in some of the tests
(more on the map_value_adj though), but it would be good to keep
tracking this specifically as well.

Thanks a lot,
Daniel
