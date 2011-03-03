From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] RxRPC: Fix v1 keys
Date: Wed, 02 Mar 2011 22:19:51 -0800 (PST)
Message-ID: <20110302.221951.28823654.davem@davemloft.net>
References: <20110228132753.30463.24909.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	anton@samba.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39422
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755068Ab1CCGTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 01:19:15 -0500
In-Reply-To: <20110228132753.30463.24909.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Mon, 28 Feb 2011 13:27:53 +0000

> From: Anton Blanchard <anton@au1.ibm.com>
> 
> commit 339412841d7 (RxRPC: Allow key payloads to be passed in XDR form)
> broke klog for me. I notice the v1 key struct had a kif_version field
> added:
> 
> -struct rxkad_key {
> -       u16     security_index;         /* RxRPC header security index */
> -       u16     ticket_len;             /* length of ticket[] */
> -       u32     expiry;                 /* time at which expires */
> -       u32     kvno;                   /* key version number */
> -       u8      session_key[8];         /* DES session key */
> -       u8      ticket[0];              /* the encrypted ticket */
> -};
> 
> +struct rxrpc_key_data_v1 {
> +       u32             kif_version;            /* 1 */
> +       u16             security_index;
> +       u16             ticket_length;
> +       u32             expiry;                 /* time_t */
> +       u32             kvno;
> +       u8              session_key[8];
> +       u8              ticket[0];
> +};
> 
> However the code in rxrpc_instantiate strips it away:
> 
> 	data += sizeof(kver);
> 	datalen -= sizeof(kver);
> 
> Removing kif_version fixes my problem.
> 
> Signed-off-by: Anton Blanchard <anton@samba.org>
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied.
