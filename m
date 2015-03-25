From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2] iproute2: unify naming for entries offloaded
 to hardware
Date: Tue, 24 Mar 2015 21:28:46 -0700
Message-ID: <5512397E.1030706@cumulusnetworks.com>
References: <1427243585-1530-1-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"John W. Linville" <linville@tuxdriver.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:33855 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbbCYE2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 00:28:48 -0400
Received: by pdbni2 with SMTP id ni2so15490743pdb.1
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 21:28:47 -0700 (PDT)
In-Reply-To: <1427243585-1530-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/24/15, 5:33 PM, Andy Gospodarek wrote:
> The kernel now has the capability to offload FDB and FIB entries to hardware.
> It is important to let users know if table entries are also offloaded to
> hardware.  Currently offloaded FDB entries are indicated by the existence of
> the flag 'external' on the entry as of the following commit:
>
> commit 28467b7f3facd6114b2fbe0c9fecf57adbd52e12
> Author: Scott Feldman <sfeldma@gmail.com>
> Date:   Thu Dec 4 09:57:15 2014 +0100
>
>      bridge/fdb: add flag/indication for FDB entry synced from offload device
>
> When the patch to add support for indicating that FIB entries were also
> offloaded as posted to netdev by Scott Feldman it became clear that 'external'
> would not be an ideal name for routes.  There could definitely be confusion
> about what this might mean since many routes are to external networks -- a
> collision/confusion that did not happen with FDB.
>
> Scott Feldman asked me to check with others and build concensus around a name.
> After speaking with several people about this I am proposing we refer to both
> FDB and FIB entries that are currently backed by hardware (based on the work
> done in rocker) with the flag 'offload' appended to the end ofthe entry.
>
> Some people liked the string 'external,' others liked 'hardware,' but the point
> is to communicate that these routes are available to something that will will
> offload the forwarding normally done by the kernel.  Since the term 'offload'
> is used so frequently it seems appropriate to use the same language in
> ip/bridge output.
>
> The term 'offload' also seems to resonate with many of the people who have
> responded on Scott's original thread or to those who I reached out to directly
> and did respond to my query, so it seems we have reached consensus that it
> should be the term used going forward.
>
> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> CC: Jamal Hadi Salim <jhs@mojatatu.com>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: Jiri Pirko <jiri@resnulli.us>
> CC: John W. Linville <linville@tuxdriver.com>
> CC: Roopa Prabhu <roopa@cumulusnetworks.com>
> CC: Scott Feldman <sfeldma@gmail.com>
> CC: Stephen Hemminger <stephen@networkplumber.org>
> ---
>   bridge/fdb.c | 2 +-
>   ip/iproute.c | 2 ++
>   2 files changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/bridge/fdb.c b/bridge/fdb.c
> index 3c33e22..e34933b 100644
> --- a/bridge/fdb.c
> +++ b/bridge/fdb.c
> @@ -159,7 +159,7 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
>   	if (r->ndm_flags & NTF_ROUTER)
>   		fprintf(fp, "router ");
>   	if (r->ndm_flags & NTF_EXT_LEARNED)
> -		fprintf(fp, "external ");
> +		fprintf(fp, "offload ");
>   
>   	fprintf(fp, "%s\n", state_n2a(r->ndm_state));
>   	return 0;
> diff --git a/ip/iproute.c b/ip/iproute.c
> index 024d401..34a5216 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -412,6 +412,8 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
>   		fprintf(fp, "onlink ");
>   	if (r->rtm_flags & RTNH_F_PERVASIVE)
>   		fprintf(fp, "pervasive ");
> +	if (r->rtm_flags & RTNH_F_EXTERNAL)
> +		fprintf(fp, "offload ");
>   	if (r->rtm_flags & RTM_F_NOTIFY)
>   		fprintf(fp, "notify ");
>   	if (tb[RTA_MARK]) {
Thanks andy. This looks good.

Since the flag is part of uapi, I would prefer the flag renamed to 
RTNH_F_OFFLOAD too.
What do others feel ?. It can be a subsequent patch if there are votes.
