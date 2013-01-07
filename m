From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 19/19] netfilter: gre: fix resource leak when unregister
 gre proto
Date: Mon, 07 Jan 2013 09:27:37 +0800
Message-ID: <50EA2489.3070309@cn.fujitsu.com>
References: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com> <1356662206-2260-20-git-send-email-gaofeng@cn.fujitsu.com> <20130105035048.GA20027@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	canqunzhang@gmail.com, kaber@trash.net, ebiederm@xmission.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64025 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752664Ab3AGB2b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jan 2013 20:28:31 -0500
In-Reply-To: <20130105035048.GA20027@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pablo,

On 01/05/13 11:50, Pablo Neira Ayuso wrote:
> Hi Gao,
> 
> On Fri, Dec 28, 2012 at 10:36:46AM +0800, Gao feng wrote:
>> Currectly we unregister proto before all conntrack entries of
>> this proto being destroyed. so in function destroy_conntrack
>> we can't find proper l4proto to call l4proto->destroy.
>> this will cause resource leak.
> 
> Good catch.
> 
> But better to remove the entries before unregistering the protocol
> tracker, so l4proto->destroy is always called.
> 

I think the reason we unregister proto before remove all entries
is to avoid new entry for this protocol being created.

If we remove all contrack entries before unregistration, there maybe
some new entries being created between nf_ct_iterate_cleanup and
nf_conntrack_l4proto_unregister_net.this will cause some terrible things.

SO I think we should make proto unavailable first,remove all entries next,
and remove proto from nf_ct_protos arrays finally.
