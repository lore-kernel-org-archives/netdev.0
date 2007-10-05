From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9128] New: PF_KEY SADB_GET messages return
 SADB_DUMP from the kernel
Date: Fri, 5 Oct 2007 10:37:55 -0700
Message-ID: <20071005103755.a1c86e7d.akpm@linux-foundation.org>
References: <bug-9128-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org,
	Joy Latten <latten@austin.ibm.com>,
	Eric Paris <eparis@parisplace.org>,
	James Morris <jmorris@namei.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org, chardin@2wire.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58637 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751570AbXJERjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 13:39:45 -0400
In-Reply-To: <bug-9128-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


(Please reply via emailed reply-to-all, not via the bugzilla web interface)

On Fri,  5 Oct 2007 09:01:50 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9128
> 
>            Summary: PF_KEY SADB_GET messages return SADB_DUMP from the
>                     kernel
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.18
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: chardin@2wire.com
> 
> 
> Most recent kernel where this bug did not occur:
> Distribution: Centos 5
> Hardware Environment: Dell 490
> Software Environment: Centos 5
> Problem Description:
> Sending an SADB_GET to the PF_KEY socket returns an SADB_DUMP in the out_hdr
> 
> Steps to reproduce:
> Send an SADB_GET to the PF_KEY socket and dump the returned packet
> 
> 
> This patch should fix the problem
> diff --git a/net/key/af_key.c b/net/key/af_key.c
> index 5502df1..7a5e993 100644
> --- a/net/key/af_key.c
> +++ b/net/key/af_key.c
> @@ -1546,7 +1546,7 @@ static int pfkey_get(struct sock *sk, struct sk_buff
> *skb,
> 
>         out_hdr = (struct sadb_msg *) out_skb->data;
>         out_hdr->sadb_msg_version = hdr->sadb_msg_version;
> -       out_hdr->sadb_msg_type = SADB_DUMP;
> +       out_hdr->sadb_msg_type = SADB_GET;
>         out_hdr->sadb_msg_satype = pfkey_proto2satype(proto);
>         out_hdr->sadb_msg_errno = 0;
>         out_hdr->sadb_msg_reserved = 0;
> 

Please submit kernel patches via email, as per
http://www.zip.com.au/~akpm/linux/patches/stuff/tpp.txt.  Net patches
should be sent to netdev@vger.kernel.org and perhaps
linux-kernel@vger.kernel.org.

But whatever - I can convert this patch into a suitable one and send it in
to David if people think it is good?

