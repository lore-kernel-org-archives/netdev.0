From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH iproute2 2/2] lib/libnetlink: update rtnl_talk to support
 malloc buff at run time
Date: Fri, 8 Sep 2017 13:06:52 +0200
Message-ID: <20170908110652.GU2399@orbyte.nwl.cc>
References: <1504865697-27274-1-git-send-email-liuhangbin@gmail.com>
 <1504865697-27274-3-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Michal Kubecek <mkubecek@suse.cz>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:36908 "EHLO orbyte.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751577AbdIHLGx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 8 Sep 2017 07:06:53 -0400
Content-Disposition: inline
In-Reply-To: <1504865697-27274-3-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hangbin,

On Fri, Sep 08, 2017 at 06:14:57PM +0800, Hangbin Liu wrote:
[...]
> diff --git a/genl/ctrl.c b/genl/ctrl.c
> index 448988e..699657b 100644
> --- a/genl/ctrl.c
> +++ b/genl/ctrl.c
> @@ -55,6 +55,7 @@ int genl_ctrl_resolve_family(const char *family)
>  	};
>  	struct nlmsghdr *nlh = &req.n;
>  	struct genlmsghdr *ghdr = &req.g;
> +	struct nlmsghdr *answer = NULL;

I don't think it's necessary to assign NULL here or in any of the other
cases.

>  	if (rtnl_open_byproto(&rth, 0, NETLINK_GENERIC) < 0) {
>  		fprintf(stderr, "Cannot open generic netlink socket\n");
> @@ -63,19 +64,19 @@ int genl_ctrl_resolve_family(const char *family)
>  
>  	addattr_l(nlh, 128, CTRL_ATTR_FAMILY_NAME, family, strlen(family) + 1);
>  
> -	if (rtnl_talk(&rth, nlh, nlh, sizeof(req)) < 0) {
> +	if (rtnl_talk(&rth, nlh, &answer) < 0) {

I didn't check, but it's likely that at least in some cases 'nlh'
contains some buffer space to hold the answer (if it will be larger than
the input). If so, this could be dropped since the buffer is no longer
reused.

Apart from that, looks good to me!

Thanks, Phil
