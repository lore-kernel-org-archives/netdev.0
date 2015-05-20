From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 1/4] bpf: allow bpf programs to tail-call other
 bpf programs
Date: Tue, 19 May 2015 17:18:44 -0700
Message-ID: <555BD2E4.5050608@plumgrid.com>
References: <1432079946-9878-1-git-send-email-ast@plumgrid.com> <1432079946-9878-2-git-send-email-ast@plumgrid.com> <CALCETrVP=7sCM12cCZVZCCMozGcHyqTsOFvjv7cEpc7Frxj4Xg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Zi Shen Lim <zlim.lnx@gmail.com>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALCETrVP=7sCM12cCZVZCCMozGcHyqTsOFvjv7cEpc7Frxj4Xg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/19/15 5:13 PM, Andy Lutomirski wrote:
>
> IMO this is starting to get a bit ugly.  Would it be possible to have
> the program dereference the subprogram reference itself from the jump
> table?  There would have to be a verifier type that represents a
> reference to a program tail-call entry point, but that seems better
> than having this weird indirection.

Which part? I don't think you've looked at examples yet.
network parser has to call itself. Otherwise we cannot parse 10 mpls
labels or TLVs.
Indirection via jump_table also has to be there.
We need to dynamically add and remove programs form this jump table.
It cannot be all static.
