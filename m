From: Vasiliy Kulikov <segooon@gmail.com>
Subject: Re: [PATCH 05/14] userns: clamp down users of cap_raised
Date: Fri, 29 Jul 2011 03:23:37 +0400
Message-ID: <20110728232337.GA9186@albatros>
References: <1311706717-7398-1-git-send-email-serge@hallyn.com>
 <1311706717-7398-6-git-send-email-serge@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org, dhowells@redhat.com,
	ebiederm@xmission.com
To: Serge Hallyn <serge@hallyn.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1311706717-7398-6-git-send-email-serge@hallyn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 26, 2011 at 18:58 +0000, Serge Hallyn wrote:
> From: Serge E. Hallyn <serge.hallyn@canonical.com>
> 
> A few modules are using cap_raised(current_cap(), cap) to authorize
> actions, but the privilege should be applicable against the initial
> user namespace.  Refuse privilege if the caller is not in init_user_ns.
> 
> Signed-off-by: Serge E. Hallyn <serge.hallyn@canonical.com>
> Cc: Eric W. Biederman <ebiederm@xmission.com>
> ---
>  drivers/block/drbd/drbd_nl.c           |    5 +++++
>  drivers/md/dm-log-userspace-transfer.c |    3 +++
>  drivers/staging/pohmelfs/config.c      |    3 +++
>  drivers/video/uvesafb.c                |    3 +++
>  4 files changed, 14 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/block/drbd/drbd_nl.c b/drivers/block/drbd/drbd_nl.c
> index 515bcd9..7717f8a 100644
> --- a/drivers/block/drbd/drbd_nl.c
> +++ b/drivers/block/drbd/drbd_nl.c
> @@ -2297,6 +2297,11 @@ static void drbd_connector_callback(struct cn_msg *req, struct netlink_skb_parms
>  		return;
>  	}
>  
> +	if (current_user_ns() != &init_user_ns) {
[...]
>  	if (!cap_raised(current_cap(), CAP_SYS_ADMIN)) {
[...]

Looks like it is an often pattern.  Maybe move both checks to a
function?


Thanks,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments
