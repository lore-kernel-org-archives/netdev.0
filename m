From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] ss: fix the incorrect value of total UNIX_DIAG_*
 number
Date: Wed, 25 Apr 2012 13:21:26 -0700
Message-ID: <20120425132126.6859f1be@nehalam.linuxnetplumber.net>
References: <4F97A484.2040300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: xemul@parallels.com, NetDev <netdev@vger.kernel.org>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56445 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758558Ab2DYUVb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 16:21:31 -0400
In-Reply-To: <4F97A484.2040300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 25 Apr 2012 15:15:16 +0800
Shan Wei <shanwei88@gmail.com> wrote:

> From: Shan Wei <davidshan@tencent.com>
> 
> UNIX_DIAG_MAX is included in enum type.
> It is equal to the total number of enum element.
> 
> But lots of enum MAX value is defined as the max enum element, e.g. INET_DIAG_MAX, XFRMA_MAX. 
> The right fixing way seems to define UNIX_DIAG_MAX as UNIX_DIAG_MEMINFO,
> but this way will break other user application.
> 
> So, just fix it on user application.
> 
> 
> Signed-off-by: Shan Wei <davidshan@tencent.com>
> ---
>  misc/ss.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/misc/ss.c b/misc/ss.c
> index 4017918..5f70a26 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -2011,12 +2011,12 @@ void unix_list_print(struct unixstat *list, struct filter *f)
>  static int unix_show_sock(struct nlmsghdr *nlh, struct filter *f)
>  {
>  	struct unix_diag_msg *r = NLMSG_DATA(nlh);
> -	struct rtattr *tb[UNIX_DIAG_MAX+1];
> +	struct rtattr *tb[UNIX_DIAG_MAX];
>  	char name[128];
>  	int peer_ino;
>  	int rqlen;
>  
> -	parse_rtattr(tb, UNIX_DIAG_MAX, (struct rtattr*)(r+1),
> +	parse_rtattr(tb, UNIX_DIAG_MAX-1, (struct rtattr*)(r+1),
>  		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
>  
>  	if (netid_width)

Ok, I'll put this in but with a big juicy comment so that nobody
else is surprised by the fact we got it wrong here.
