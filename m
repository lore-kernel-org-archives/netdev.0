From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip xfrm: use correct key length for netlink
 message
Date: Sun, 1 Oct 2017 13:48:52 -0700
Message-ID: <20171001134852.5aadf10b@xeon-e3>
References: <20170929114105.2D971A0F6B@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:47559 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751773AbdJAUtA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2017 16:49:00 -0400
Received: by mail-pg0-f50.google.com with SMTP id d8so2041480pgt.4
        for <netdev@vger.kernel.org>; Sun, 01 Oct 2017 13:48:59 -0700 (PDT)
In-Reply-To: <20170929114105.2D971A0F6B@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Sep 2017 13:41:05 +0200 (CEST)
Michal Kubecek <mkubecek@suse.cz> wrote:

> When SA is added manually using "ip xfrm state add", xfrm_state_modify()
> uses alg_key_len field of struct xfrm_algo for the length of key passed to
> kernel in the netlink message. However alg_key_len is bit length of the key
> while we need byte length here. This is usually harmless as kernel ignores
> the excess data but when the bit length of the key exceeds 512
> (XFRM_ALGO_KEY_BUF_SIZE), it can result in buffer overflow.
> 
> We can simply divide by 8 here as the only place setting alg_key_len is in
> xfrm_algo_parse() where it is always set to a multiple of 8 (and there are
> already multiple places using "algo->alg_key_len / 8").
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

This looks correct applied.
