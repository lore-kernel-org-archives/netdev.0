From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netfilter: Fix br_nf_pre_routing() in conjunction with
 bridge-nf-call-ip(6)tables=0
Date: Tue, 3 Jan 2012 08:15:21 -0800
Message-ID: <20120103081521.2fec3a29@nehalam.linuxnetplumber.net>
References: <4F025A07.2000304@nod.at>
	<1325597164-13459-1-git-send-email-richard@nod.at>
	<1325597164-13459-2-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Richard Weinberger <richard@nod.at>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1325597164-13459-2-git-send-email-richard@nod.at>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue,  3 Jan 2012 14:26:04 +0100
Richard Weinberger <richard@nod.at> wrote:

> If net.bridge.bridge-nf-call-iptables or net.bridge.bridge-nf-call-ip6tables
> are set to zero xt_physdev has no effect because skb->nf_bridge has not been set up.
> 
> Signed-off-by: Richard Weinberger <richard@nod.at>

I am not sure if this is a valid configuration. The setting of sysctl is saying
"don't do iptables on bridge (since I won't be using it)" and then you are later
doing iptables and expecting the settings as if the iptables setup was being
done.

Instead, you should just enable the net.bridge.bridge-nf-call-iptables sysctl.
If a distro chooses to disable it then you may have to do it explicitly.

