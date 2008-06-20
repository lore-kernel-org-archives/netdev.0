From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: unlock iptables in netns
Date: Fri, 20 Jun 2008 21:54:51 +0400
Message-ID: <20080620175107.GA5085@martell.zuzino.mipt.ru>
References: <200806102127.21093.adobriyan@parallels.com> <484F7663.1080408@trash.net> <48563FBB.4080303@trash.net> <20080616110434.GA5103@martell.zuzino.mipt.ru> <48564B70.2020400@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	devel@openvz.org, den@openvz.org, xemul@openvz.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <48564B70.2020400@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 16, 2008 at 01:16:00PM +0200, Patrick McHardy wrote:
> Alexey Dobriyan wrote:
>> On Mon, Jun 16, 2008 at 12:26:03PM +0200, Patrick McHardy wrote:
>>>
>>> By the way, is there already work done for conntrack/NAT namespace
>>> support? I have this patch that uses marks for something very similar
>>> that should be easy to adjust.
>> Yes, right now I'm fighting something which looks like double free
>> of conntrack during clone(CLONE_NEWNET)/exit test despite none created
>> in netns. And unknown to me dimensions of input and output packet 
>> codepaths.
>> :^)
>> Preliminaty details:
>> 	struct nf_conn::ct_net which pins netns

Ouch, now that I have converted conntracking code, "pins netns" part is
really stupid, just background traffic on network will prevent netns from
destroying.

