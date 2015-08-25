From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCHv5 net-next 10/10] openvswitch: Allow attaching helpers to
 ct action
Date: Tue, 25 Aug 2015 20:33:02 +0200
Message-ID: <20150825183302.GN3707@pox.localdomain>
References: <1440462740-23358-1-git-send-email-joestringer@nicira.com>
 <1440462740-23358-11-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pshelar@nicira.com,
	linux-kernel@vger.kernel.org, pablo@netfilter.org,
	fwestpha@redhat.com, hannes@redhat.com, jpettit@nicira.com,
	jesse@nicira.com, netfilter-devel@vger.kernel.org
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1440462740-23358-11-git-send-email-joestringer@nicira.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/24/15 at 05:32pm, Joe Stringer wrote:
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

Not subject to this patch but we may want to revisit the syntax of the
state flags. It's neatly compressed like this but ct_state=untracked
ct_state=related might be more readable. The +trk should be implicit
for anything !untracked

> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
