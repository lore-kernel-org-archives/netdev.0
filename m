From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net-next 1/3] bpf: enable non-root eBPF programs
Date: Fri, 9 Oct 2015 10:59:23 -0700
Message-ID: <5618007B.70907@plumgrid.com>
References: <1444281803-24274-1-git-send-email-ast@plumgrid.com>
 <1444281803-24274-2-git-send-email-ast@plumgrid.com>
 <1444328452.3935641.405110585.76554E06@webmail.messagingengine.com>
 <5616E8A8.5020809@plumgrid.com> <87mvvsb6zg.fsf@stressinduktion.org>
 <5617F9C9.10407@plumgrid.com> <5617FD1C.2030702@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@amacapital.net>,
	Ingo Molnar <mingo@kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5617FD1C.2030702@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/9/15 10:45 AM, Daniel Borkmann wrote:
> On 10/09/2015 07:30 PM, Alexei Starovoitov wrote:
> ...
>> Openstack use case is different. There it will be prog_type_sched_cls
>> that can mangle packets, change skb metadata, etc under TC framework.
>> These are not suitable for all users and this patch leaves
>> them root-only. If you're proposing to add CAP_BPF_TC to let containers
>> use them without being CAP_SYS_ADMIN, then I agree, it is useful, but
>> needs a lot more safety analysis on tc side.
>
> Well, I think if so, then this would need to be something generic for
> tc instead of being specific to a single (out of various) entities
> inside the tc framework, but I currently doubt that this makes much
> sense. If we allow to operate already at that level, then restricting
> to CAP_SYS_ADMIN makes more sense in that specific context/subsys to me.

Let me rephrase. I think it would be useful, but I have my doubts that
it's manageable, since analyzing dark corners of TC is not trivial.
Probably easier to allow prog_type_sched_cls/act under CAP_NET_ADMIN
and grant that to trusted apps. Though only tiny bit better than
requiring CAP_SYS_ADMIN.
