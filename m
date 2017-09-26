From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net-next] bpf/verifier: improve disassembly of BPF_END
 instructions
Date: Tue, 26 Sep 2017 15:37:12 +0100
Message-ID: <efc5b258-51bd-8007-7fe2-5b08d78234f4@solarflare.com>
References: <46aa4442-b8ed-e4c1-4897-8f650e23d448@solarflare.com>
 <CAH3MdRVK-=pL8YCz44BPCmHhuZE_CRfih0QdZPLa=mpE_uoA_Q@mail.gmail.com>
 <ec7d0485-11f4-4fdb-0b87-1fb0afdb4f11@solarflare.com>
 <CAH3MdRVCf_wLoC7WOfaL2L2px3aYVWUhWxarMsyJdD7_E9fv_Q@mail.gmail.com>
 <CAH3MdRXgVtVjhYQkRopPKvL+4+NaTRRJoJq6XD_S-Dra69j0hA@mail.gmail.com>
 <20170922151614.bg4ovrp6m27cppr7@ast-mbp>
 <7c1ab2b8-e65d-3b09-f9f0-9fd13c1ceccf@solarflare.com>
 <CAH3MdRUCPNzXHQRQtVp7-p9XLDbJrkhxYEe=c0Fkt4+D9Tk9sw@mail.gmail.com>
 <20170924055016.w6x5tj6kjxjbocpl@ast-mbp> <59C978A2.6070405@iogearbox.net>
 <20170926013259.cwnpnshay4rxnmyr@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Y Song <ys114321@gmail.com>, David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Jiong Wang <jiong.wang@netronome.com>,
        "Jakub Kicinski" <jakub.kicinski@netronome.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([148.163.129.52]:58240 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S966814AbdIZOhW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 10:37:22 -0400
In-Reply-To: <20170926013259.cwnpnshay4rxnmyr@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/09/17 02:33, Alexei Starovoitov wrote:
> On Mon, Sep 25, 2017 at 11:44:02PM +0200, Daniel Borkmann wrote:
>> But above cast to be16 also doesn't seem quite C-like in terms
>> of what we're actually doing... 3rd option would be my personal
>> preference even if it doesn't look C-like, but otoh we also have
>> 'call' etc which is neither.

<snip>

> In that sense (be16) cast is pretty much self explanatory.
> So I'd like to continue bikesheding in hopes to convince you
> to accept either 1 or 2 above ;)
I agree with Daniel.  3rd option `r1 = be16 r1` is best, as it's an
 actual ALU operation, not just a cast.  And since it looks like we're
 drifting vaguely near a consensus on that (even if Alexei still isn't
 convinced ;-) I'll spin v2 patches with that and `r1 = (u32) -r1`, so
 we have something concrete to argue about...

-Ed
