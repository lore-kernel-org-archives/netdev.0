From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] RxRPC: Fix v1 keys
Date: Mon, 28 Feb 2011 15:01:09 -0800
Message-ID: <20110228150109.352d0713.akpm@linux-foundation.org>
References: <20110228132753.30463.24909.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Anton Blanchard <anton@samba.org>
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45677 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753421Ab1B1XBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 18:01:51 -0500
In-Reply-To: <20110228132753.30463.24909.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Feb 2011 13:27:53 +0000
David Howells <dhowells@redhat.com> wrote:

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
> ---
> 
>  include/keys/rxrpc-type.h |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/include/keys/rxrpc-type.h b/include/keys/rxrpc-type.h
> index 5cb86c3..fc48754 100644
> --- a/include/keys/rxrpc-type.h
> +++ b/include/keys/rxrpc-type.h
> @@ -99,7 +99,6 @@ struct rxrpc_key_token {
>   * structure of raw payloads passed to add_key() or instantiate key
>   */
>  struct rxrpc_key_data_v1 {
> -	u32		kif_version;		/* 1 */
>  	u16		security_index;
>  	u16		ticket_length;
>  	u32		expiry;			/* time_t */

Isn't the patch also needed in 2.6.37.x?
