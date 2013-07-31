From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next] tcp_metrics: rearrange fields to avoid holes
Date: Tue, 30 Jul 2013 20:08:10 -0700
Message-ID: <1375240090.10515.53.camel@edumazet-glaptop>
References: <1375238905-6423-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:59366 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751683Ab3GaDIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 23:08:12 -0400
Received: by mail-pd0-f172.google.com with SMTP id z10so205694pdj.17
        for <netdev@vger.kernel.org>; Tue, 30 Jul 2013 20:08:12 -0700 (PDT)
In-Reply-To: <1375238905-6423-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-31 at 10:48 +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> On x86_64, before this patch:
> 
> struct tcp_fastopen_metrics {
> 	u16                        mss;                  /*     0     2 */
> 	u16                        syn_loss:10;          /*     2: 6  2 */
> 
> 	/* XXX 6 bits hole, try to pack */
> 	/* XXX 4 bytes hole, try to pack */
> 
> 	long unsigned int          last_syn_loss;        /*     8     8 */
> 	struct tcp_fastopen_cookie cookie;               /*    16    17 */
> 
> 	/* size: 40, cachelines: 1, members: 4 */
> 	/* sum members: 29, holes: 1, sum holes: 4 */
> 	/* bit holes: 1, sum bit holes: 6 bits */
> 	/* padding: 7 */
> 	/* last cacheline: 40 bytes */
> };
> 
> after this patch:
> 
> struct tcp_fastopen_metrics {
> 	u16                        mss;                  /*     0     2 */
> 	u16                        syn_loss:10;          /*     2: 6  2 */
> 
> 	/* XXX 6 bits hole, try to pack */
> 
> 	struct tcp_fastopen_cookie cookie;               /*     4    17 */
> 
> 	/* XXX 3 bytes hole, try to pack */
> 
> 	long unsigned int          last_syn_loss;        /*    24     8 */
> 
> 	/* size: 32, cachelines: 1, members: 4 */
> 	/* sum members: 29, holes: 1, sum holes: 3 */
> 	/* bit holes: 1, sum bit holes: 6 bits */
> 	/* last cacheline: 32 bytes */
> };
> 
> On 32bit, the 4-byte hole should not exist, so this patch probably
> doesn't change anything.
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Oh well, this patch is pure noise...
