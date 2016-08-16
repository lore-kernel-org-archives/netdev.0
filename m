From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] sctp: linearize early if it's not GSO
Date: Wed, 17 Aug 2016 00:59:17 +0200
Message-ID: <57B39AC5.7000002@iogearbox.net>
References: <a4bc263e62ced9f5790932f11e7d829c36566808.1471386679.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:51909 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053AbcHPW7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 18:59:19 -0400
In-Reply-To: <a4bc263e62ced9f5790932f11e7d829c36566808.1471386679.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/17/2016 12:35 AM, Marcelo Ricardo Leitner wrote:
> Because otherwise when crc computation is still needed it's way more
> expensive than on a linear buffer to the point that it affects
> performance.
>
> It's so expensive that netperf test gives a perf output as below:
>
> Overhead  Shared Object        Symbol
>    69,44%  [kernel]             [k] gf2_matrix_square
>     2,84%  [kernel]             [k] crc32_generic_combine.part.0
>     2,78%  [kernel]             [k] _raw_spin_lock_bh

What kernel is this, seems not net kernel?

$ git grep -n gf2_matrix_square
$ git grep -n crc32_generic_combine
$

Maybe RHEL? Did you consider backporting 6d514b4e7737 et al?

> And performance goes from 2Gbit/s to 0.5Gbit/s on this test. Doing the
> linearization before checksumming is enough to restore it.
>
> Fixes: 3acb50c18d8d ("sctp: delay as much as possible skb_linearize")
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
