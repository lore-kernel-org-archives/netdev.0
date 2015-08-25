From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv5 net-next 10/10] openvswitch: Allow attaching helpers to
 ct action
Date: Tue, 25 Aug 2015 13:46:08 -0700
Message-ID: <CALnjE+qAEMRTFZ2PPam46YcrigKbi=ZRq5eE1r273-gZmAMOwg@mail.gmail.com>
References: <1440462740-23358-1-git-send-email-joestringer@nicira.com>
	<1440462740-23358-11-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, pablo <pablo@netfilter.org>,
	Florian Westphal <fwestpha@redhat.com>,
	Hannes Sowa <hannes@redhat.com>, Thomas Graf <tgraf@suug.ch>,
	Justin Pettit <jpettit@nicira.com>,
	Jesse Gross <jesse@nicira.com>, netfilter-devel@vger.kernel.org
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440462740-23358-11-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 24, 2015 at 5:32 PM, Joe Stringer <joestringer@nicira.com> wrote:
> Add support for using conntrack helpers to assist protocol detection.
> The new OVS_CT_ATTR_HELPER attribute of the CT action specifies a helper
> to be used for this connection. If no helper is specified, then helpers
> will be automatically applied as per the sysctl configuration of
> net.netfilter.nf_conntrack_helper.
>
> The helper may be specified as part of the conntrack action, eg:
> ct(helper=ftp). Initial packets for related connections should be
> committed to allow later packets for the flow to be considered
> established.
>
> Example ovs-ofctl flows allowing FTP connections from ports 1->2:
> in_port=1,tcp,action=ct(helper=ftp,commit),2
> in_port=2,tcp,ct_state=-trk,action=ct(recirc)
> in_port=2,tcp,ct_state=+trk-new+est,action=1
> in_port=2,tcp,ct_state=+trk+rel,action=1
>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Acked-by: Pravin B Shelar <pshelar@nicira.com>
