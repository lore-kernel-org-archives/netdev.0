From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Patch net-next v2] pktgen: support net namespace
Date: Mon, 28 Jan 2013 18:36:02 -0800
Message-ID: <874ni0k965.fsf@xmission.com>
References: <1359424389-21919-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:58936 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751351Ab3A2CgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 21:36:14 -0500
In-Reply-To: <1359424389-21919-1-git-send-email-amwang@redhat.com> (Cong
	Wang's message of "Tue, 29 Jan 2013 09:53:09 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <amwang@redhat.com> writes:

> From: Cong Wang <amwang@redhat.com>
>
> v2: remove a useless check
>
> This patch add net namespace to pktgen, so that
> we can use pktgen in different namespaces.
>
> Cc: Eric W. Biederman <ebiederm@xmission.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
>
> ---
>  net/core/pktgen.c |  123 +++++++++++++++++++++++++++++++++++------------------
>  1 files changed, 81 insertions(+), 42 deletions(-)

Skiming through this again I have spotted what looks like a pretty
major bug.  You are limiting yourself to one network device per network
namespace when the actual limit is one network device per thread.

I think you can just kill the dev member of pktgen_net and the two or
three lines of code that touch it.

> +static int pg_net_id __read_mostly;
> +
> +struct pktgen_net {
> +	struct net		*net;
> +	struct net_device	*dev;
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> +	struct proc_dir_entry	*proc_dir;
>  };

Eric
