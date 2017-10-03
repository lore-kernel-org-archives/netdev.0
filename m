From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/3] ss: allow AF_FAMILY constants >32
Date: Tue, 3 Oct 2017 11:26:53 -0700
Message-ID: <20171003112653.213c7cb3@xeon-e3>
References: <20171003175744.24987-1-stefanha@redhat.com>
        <20171003175744.24987-2-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jorgen Hansen <jhansen@vmware.com>,
        Dexuan Cui <decui@microsoft.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:52294 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751111AbdJCS1B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 14:27:01 -0400
Received: by mail-pf0-f172.google.com with SMTP id a1so1764000pfj.9
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 11:27:01 -0700 (PDT)
In-Reply-To: <20171003175744.24987-2-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  3 Oct 2017 13:57:42 -0400
Stefan Hajnoczi <stefanha@redhat.com> wrote:

> Linux has more than 32 address families defined in <bits/socket.h>.  Use
> a 64-bit type so all of them can be represented in the filter->families
> bitmask.
> 
> It's easy to introduce bugs when using (1 << AF_FAMILY) because the
> value is 32-bit.  This can produce incorrect results from bitmask
> operations so introduce the FAMILY_MASK() macro to eliminate these bugs.
> 
> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
> ---
>  misc/ss.c | 54 ++++++++++++++++++++++++++++--------------------------
>  1 file changed, 28 insertions(+), 26 deletions(-)
> 
> diff --git a/misc/ss.c b/misc/ss.c
> index dd8dfaa4..12a31c90 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -170,55 +170,57 @@ enum {
>  struct filter {
>  	int dbs;
>  	int states;
> -	int families;
> +	__u64 families;

Since this isn't a value that is coming from kernel. It should be uint64_t
rather than __u64.
