From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cipso: handle CIPSO options correctly when NetLabel is
 disabled
Date: Thu, 31 May 2012 19:07:05 -0400 (EDT)
Message-ID: <20120531.190705.3612500429295140.davem@davemloft.net>
References: <20120531200922.6265.81763.stgit@sifl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	stable@kernel.org
To: pmoore@redhat.com
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20120531200922.6265.81763.stgit@sifl>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <pmoore@redhat.com>
Date: Thu, 31 May 2012 16:09:23 -0400

> When NetLabel is not enabled, e.g. CONFIG_NETLABEL=n, and the system
> receives a CIPSO tagged packet it is dropped (cipso_v4_validate()
> returns non-zero).  In most cases this is the correct and desired
> behavior, however, in the case where we are simply forwarding the
> traffic, e.g. acting as a network bridge, this becomes a problem.
> 
> This patch fixes the forwarding problem by providing the basic CIPSO
> validation code directly in ip_options_compile() without the need for
> the NetLabel or CIPSO code.  The new validation code can not perform
> any of the CIPSO option label/value verification that
> cipso_v4_validate() does, but it can verify the basic CIPSO option
> format.
> 
> The behavior when NetLabel is enabled is unchanged.
> 
> Signed-off-by: Paul Moore <pmoore@redhat.com>

I don't like this at all.

The only conclusion I can come to is that cipso_v4_validate() is doing
the wrong thing when NETLABEL is disabled.

There is never a good reason to crap all over a function with ifdefs.
This is especially true when it's being done to paper over a function
with poor semantics.

The whole idea is to abstract and put all of this kind of logic into
cipso_v4_validate().

