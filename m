From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] rhashtable: rhashtable_remove() must unlink in
 both tbl and future_tbl
Date: Wed, 21 Jan 2015 11:56:07 +0000
Message-ID: <20150121115607.GB12570@casper.infradead.org>
References: <54BCBA35.2080103@windriver.com>
 <20150119125928.GB7672@casper.infradead.org>
 <54BDC30D.5000606@windriver.com>
 <20150120165826.GK20315@casper.infradead.org>
 <54BF65C2.9010404@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net,
	"richard.alpe@ericsson.com >> Richard Alpe"
	<richard.alpe@ericsson.com>, Netdev <netdev@vger.kernel.org>,
	tipc-discussion@lists.sourceforge.net
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:36302 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742AbbAUL4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 06:56:08 -0500
Content-Disposition: inline
In-Reply-To: <54BF65C2.9010404@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/21/15 at 04:39pm, Ying Xue wrote:
> Your below changes are reasonable for me. But after I applied the patch,
> my reported two issues still happened :( And failure logs are completely
> same before.

Correct. The patch fixes the panic that you reported as well:

[   17.033416] BUG: unable to handle kernel paging request at
ffffffffffffff77
[   17.034009] IP: [<ffffffffa0019b8c>] jhash+0xec/0x160 [tipc]
[...]
[   17.034009] Call Trace:
[   17.034009]  [<ffffffff813b38e9>] head_hashfn+0x29/0x50
[   17.034009]  [<ffffffff813b475b>] rhashtable_expand+0x37b/0x680
[   17.034009]  [<ffffffff813b4b38>] rht_deferred_worker+0xd8/0xe0
[   17.034009]  [<ffffffff81074d10>] process_one_work+0x200/0x800
[   17.034009]  [<ffffffff81074c71>] ? process_one_work+0x161/0x800
[   17.034009]  [<ffffffff81074c71>] ? process_one_work+0x161/0x800
[   17.034009]  [<ffffffff8107533c>] process_scheduled_works+0x2c/0x40
[   17.034009]  [<ffffffff810758d3>] worker_thread+0x253/0x4b0
[   17.034009]  [<ffffffff81075680>] ? rescuer_thread+0x330/0x330
[   17.034009]  [<ffffffff8107bb6f>] kthread+0xef/0x110
[   17.034009]  [<ffffffff8107ba80>] ? flush_kthread_work+0x170/0x170
[   17.034009]  [<ffffffff81a44a2c>] ret_from_fork+0x7c/0xb0
[   17.034009]  [<ffffffff8107ba80>] ? flush_kthread_work+0x170/0x170
