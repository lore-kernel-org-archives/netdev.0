From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 1/2] rhashtable: unconditionally grow when max_shift
 is not specified
Date: Wed, 25 Feb 2015 17:44:50 +0100
Message-ID: <54EDFC02.2070206@iogearbox.net>
References: <cover.1424877322.git.daniel@iogearbox.net> <0973a6e9b73a2ca14477c0cf98093d5f1b3d3d40.1424877322.git.daniel@iogearbox.net> <20150225162846.GA13107@casper.infradead.org> <54EDFA16.20308@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, pablo@netfilter.org, johunt@akamai.com,
	kaber@trash.net, netdev@vger.kernel.org,
	Ying Xue <ying.xue@windriver.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58826 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753352AbbBYQo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 11:44:59 -0500
In-Reply-To: <54EDFA16.20308@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/25/2015 05:36 PM, Daniel Borkmann wrote:
> On 02/25/2015 05:28 PM, Thomas Graf wrote:
...
>> I assume you wanted this chunk in patch 2.
>
> No, it's in this chunk on purpose. ;)
>
> I've tried to explain it here in the commit message:
>
>    Given that the test case verifies shrinks/expands manually, we also
>    must remove pointer to the helper functions to explicitly avoid
>    parallel resizing on insertions/deletions. test_bucket_stats() and
>    test_rht_lookup() could also be wrapped around rhashtable mutex to
>    explicitly synchronize a walk from resizing, but I think that defeats
>    the actual test case which intended to have explicit test steps,
>    i.e. 1) inserts, 2) expands, 3) shrinks, 4) deletions, with object
>    verification after each stage.

Note, the reason of this exercise is, because the semantics of
max_shift == 0 have changed. A resize on inserts _before_ this
change was impossible, now it becomes possible, so we have to
disallow resizes (only) for the test case module specifically.
