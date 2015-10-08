From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 net-next 1/3] bpf: enable non-root eBPF programs
Date: Thu, 08 Oct 2015 20:20:52 +0200
Message-ID: <1444328452.3935641.405110585.76554E06@webmail.messagingengine.com>
References: <1444281803-24274-1-git-send-email-ast@plumgrid.com>
 <1444281803-24274-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@amacapital.net>,
	Ingo Molnar <mingo@kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444281803-24274-2-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alexei,

On Thu, Oct 8, 2015, at 07:23, Alexei Starovoitov wrote:
> The feature is controlled by sysctl kernel.unprivileged_bpf_disabled.
> This toggle defaults to off (0), but can be set true (1).  Once true,
> bpf programs and maps cannot be accessed from unprivileged process,
> and the toggle cannot be set back to false.

This approach seems fine to me.

I am wondering if it makes sense to somehow allow ebpf access per
namespace? I currently have no idea how that could work and on which
namespace type to depend or going with a prctl or even cgroup maybe. The
rationale behind this is, that maybe some namespaces like openstack
router namespaces could make usage of advanced ebpf capabilities in the
kernel, while other namespaces, especially where untrusted third parties
are hosted, shouldn't have access to those facilities.

In that way, hosters would be able to e.g. deploy more efficient
performance monitoring container (which should still need not to run as
root) while the majority of the users has no access to that. Or think
about routing instances in some namespaces, etc. etc.

Thanks,
Hannes
