From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 2/3] bpf: fix checksum fixups on bpf_skb_store_bytes
Date: Thu, 04 Aug 2016 10:27:32 +0200
Message-ID: <57A2FC74.7040701@iogearbox.net>
References: <201608041148.lftoFao6%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, davem@davemloft.net,
	alexei.starovoitov@gmail.com, tgraf@suug.ch, netdev@vger.kernel.org
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40916 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbcHDI23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 04:28:29 -0400
In-Reply-To: <201608041148.lftoFao6%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/04/2016 05:10 AM, kbuild test robot wrote:
> Hi Daniel,
>
> [auto build test WARNING on net/master]
>
> url:    https://github.com/0day-ci/linux/commits/Daniel-Borkmann/Few-BPF-helper-related-checksum-fixes/20160804-085300
> reproduce: make htmldocs
>
> All warnings (new ones prefixed by >>):
>
>     include/linux/skbuff.h:940: warning: No description found for parameter 'sk'
>>> include/linux/skbuff.h:2864: warning: No description found for parameter 'off'
>     include/net/sock.h:449: warning: No description found for parameter 'sk_padding'
>     include/net/sock.h:449: warning: No description found for parameter 'sk_rcu'
>     include/linux/netdevice.h:1889: warning: No description found for parameter 'prio_tc_map[TC_BITMASK + 1]'
>
> vim +/off +2864 include/linux/skbuff.h
>
> ^1da177e Linus Torvalds  2005-04-16  2848  }
> ^1da177e Linus Torvalds  2005-04-16  2849
> ^1da177e Linus Torvalds  2005-04-16  2850  /**
> ^1da177e Linus Torvalds  2005-04-16  2851   *	skb_postpull_rcsum - update checksum for received skb after pull
> ^1da177e Linus Torvalds  2005-04-16  2852   *	@skb: buffer to update
> ^1da177e Linus Torvalds  2005-04-16  2853   *	@start: start of data before pull
> ^1da177e Linus Torvalds  2005-04-16  2854   *	@len: length of data pulled
> ^1da177e Linus Torvalds  2005-04-16  2855   *
> ^1da177e Linus Torvalds  2005-04-16  2856   *	After doing a pull on a received packet, you need to call this to
> 84fa7933 Patrick McHardy 2006-08-29  2857   *	update the CHECKSUM_COMPLETE checksum, or set ip_summed to
> 84fa7933 Patrick McHardy 2006-08-29  2858   *	CHECKSUM_NONE so that it can be recomputed from scratch.
> ^1da177e Linus Torvalds  2005-04-16  2859   */

Alright, I move the kdoc under skb_postpull_rcsum() and also add one for
skb_postpush_rcsum() in a v2 of this set. I didn't touch it because of -net
tree, but since someone might be using 'make htmldocs' it shouldn't generate
additional warnings. So, will respin with v2!
