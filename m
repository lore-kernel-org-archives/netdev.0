From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH net-next 04/15] security: Add Linux Security Modules hook for AF_BUS sockets
Date: Mon, 09 Jul 2012 14:02:30 -0400
Message-ID: <1351229.oBBIeX2TnP@sifl>
References: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk> <1340988354-26981-5-git-send-email-vincent.sanders@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	casey@schaufler-ca.com
To: Vincent Sanders <vincent.sanders@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1340988354-26981-5-git-send-email-vincent.sanders@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, June 29, 2012 05:45:43 PM Vincent Sanders wrote:
> From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
> 
> AF_BUS implements a security hook bus_connect() to be used by LSM to
> enforce connectivity security policies.
> 
> Signed-off-by: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
> Signed-off-by: Vincent Sanders <vincent.sanders@collabora.co.uk>

In future postings, please reorder the patchset so that this patch (and the 
LSM specific patches) are applied after the actual AF_BUS implementation 
(patch 08/15 in this patchset).  This makes it easier to quickly understand 
how the LSM hooks/implementation interacts with the AF_BUS code.

A good rule of thumb that I try to follow when submitting large patchsets is 
that each patch should contain code that won't be optimized away during the 
build because there is no caller.  Sometimes that isn't possible without 
making things overly awkward, but in this particular case it shouldn't cause a 
problem.

> ---
>  include/linux/security.h |   11 +++++++++++
>  security/capability.c    |    7 +++++++
>  security/security.c      |    7 +++++++
>  3 files changed, 25 insertions(+)
> 
> diff --git a/include/linux/security.h b/include/linux/security.h
> index 4e5a73c..d30dc4a 100644
> --- a/include/linux/security.h
> +++ b/include/linux/security.h

...

> +static inline int security_bus_connect(struct socket *sock,
> +				       struct sock *other,
> +				       struct sock *newsk)
> +{
> +	return 0;
> +}
> +

Other than the AF_UNIX specific name, is there a reason why you chose not to 
reuse the unix_stream_connect() LSM hook?  The arguments are the same, and 
based on an initial quick review of the SELinux hook implementations they 
appear to do almost identical things; the permissions are different but it 
should be trivial to make that conditional on the parent socket's address 
family (SELinux does similar things with other socket operations).  Looking at 
the Smack implementation, I don't think it would be a problem there either 
(CC'd Casey for his thoughts).

I'm still reviewing the rest of the AF_BUS patches but wanted to ask this now 
in case I was missing something.

-- 
paul moore
www.paul-moore.com
