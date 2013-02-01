From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v2] packet: fix leakage of tx_ring memory
Date: Fri, 01 Feb 2013 18:25:13 +0100
Message-ID: <510BFA79.90705@redhat.com>
References: <510BF1C4.4050108@redhat.com> <1359739301-14044-1-git-send-email-phil.sutter@viprinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Johann Baudy <johann.baudy@gnu-log.net>
To: Phil Sutter <phil.sutter@viprinet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63921 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753471Ab3BARZU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2013 12:25:20 -0500
In-Reply-To: <1359739301-14044-1-git-send-email-phil.sutter@viprinet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/01/2013 06:21 PM, Phil Sutter wrote:
> When releasing a packet socket, the routine packet_set_ring() is reused
> to free rings instead of allocating them. But when calling it for the
> first time, it fills req->tp_block_nr with the value of rb->pg_vec_len
> which in the second invocation makes it bail out since req->tp_block_nr
> is greater zero but req->tp_block_size is zero.
>
> This patch solves the problem by passing a zeroed auto-variable to
> packet_set_ring() upon each invocation from packet_release().
>
> As far as I can tell, this issue exists even since 69e3c75 (net: TX_RING
> and packet mmap), i.e. the original inclusion of TX ring support into
> af_packet, but applies only to sockets with both RX and TX ring
> allocated, which is probably why this was unnoticed all the time.
>
> Signed-off-by: Phil Sutter <phil.sutter@viprinet.com>
> Cc: Johann Baudy <johann.baudy@gnu-log.net>
> Cc: Daniel Borkmann <dborkman@redhat.com>

Acked-by: Daniel Borkmann <dborkman@redhat.com>
