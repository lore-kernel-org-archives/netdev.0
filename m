From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next 1/3] bpf: enable non-root eBPF programs
Date: Fri, 09 Oct 2015 19:45:00 +0200
Message-ID: <5617FD1C.2030702@iogearbox.net>
References: <1444281803-24274-1-git-send-email-ast@plumgrid.com> <1444281803-24274-2-git-send-email-ast@plumgrid.com> <1444328452.3935641.405110585.76554E06@webmail.messagingengine.com> <5616E8A8.5020809@plumgrid.com> <87mvvsb6zg.fsf@stressinduktion.org> <5617F9C9.10407@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@amacapital.net>,
	Ingo Molnar <mingo@kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35910 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932850AbbJIRpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 13:45:08 -0400
In-Reply-To: <5617F9C9.10407@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/09/2015 07:30 PM, Alexei Starovoitov wrote:
...
> Openstack use case is different. There it will be prog_type_sched_cls
> that can mangle packets, change skb metadata, etc under TC framework.
> These are not suitable for all users and this patch leaves
> them root-only. If you're proposing to add CAP_BPF_TC to let containers
> use them without being CAP_SYS_ADMIN, then I agree, it is useful, but
> needs a lot more safety analysis on tc side.

Well, I think if so, then this would need to be something generic for
tc instead of being specific to a single (out of various) entities
inside the tc framework, but I currently doubt that this makes much
sense. If we allow to operate already at that level, then restricting
to CAP_SYS_ADMIN makes more sense in that specific context/subsys to me.

Best,
Daniel
