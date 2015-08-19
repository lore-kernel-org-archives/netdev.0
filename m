From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv4 net-next 05/10] openvswitch: Add conntrack action
Date: Wed, 19 Aug 2015 13:30:24 -0700
Message-ID: <CALnjE+pJXjgxhjZV1VXVDjZyvM1d7Zb3FYtGsFyuXDYyqokZGg@mail.gmail.com>
References: <1439941188-19293-1-git-send-email-joestringer@nicira.com>
	<1439941188-19293-6-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, pablo <pablo@netfilter.org>,
	Florian Westphal <fwestpha@redhat.com>,
	Hannes Sowa <hannes@redhat.com>, Thomas Graf <tgraf@suug.ch>,
	Justin Pettit <jpettit@nicira.com>,
	Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439941188-19293-6-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 18, 2015 at 4:39 PM, Joe Stringer <joestringer@nicira.com> wrote:
> Expose the kernel connection tracker via OVS. Userspace components can
> make use of the "ct()" action, followed by "recirculate", to populate
> the conntracking state in the OVS flow key, and subsequently match on
> that state.
>
> Example ODP flows allowing traffic from 1->2, only replies from 2->1:
> in_port=1,tcp,action=ct(commit,zone=1),2
> in_port=2,ct_state=-trk,tcp,action=ct(zone=1),recirc(1)
> recirc_id=1,in_port=2,ct_state=+trk+est-new,tcp,action=1
>
> IP fragments are handled by transparently assembling them as part of the
> ct action. The maximum received unit (MRU) size is tracked so that
> refragmentation can occur during output.
>
> IP frag handling contributed by Andy Zhou.
>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> Signed-off-by: Justin Pettit <jpettit@nicira.com>
> Signed-off-by: Andy Zhou <azhou@nicira.com>
Acked-by: Pravin B Shelar <pshelar@nicira.com>
