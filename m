From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next RFC] tc: introduce OpenFlow classifier
Date: Thu, 22 Jan 2015 10:50:34 -0500
Message-ID: <54C11C4A.1070206@mojatatu.com>
References: <1421933824-17916-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:51836 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244AbbAVPug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 10:50:36 -0500
Received: by mail-ie0-f176.google.com with SMTP id rd18so2032134iec.7
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 07:50:36 -0800 (PST)
In-Reply-To: <1421933824-17916-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/15 08:37, Jiri Pirko wrote:
> This patch introduces OpenFlow-based filter. So far, the very essential
> packet fields are supported (according to OpenFlow v1.4 spec).
>
> Known issues: skb_flow_dissect hashes out ipv6 addresses. That needs
> to be changed to store them somewhere so they can be used later on.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>   include/uapi/linux/pkt_cls.h |  33 +++
>   net/sched/Kconfig            |  11 +
>   net/sched/Makefile           |   1 +
>   net/sched/cls_openflow.c     | 514 +++++++++++++++++++++++++++++++++++++++++++
>   4 files changed, 559 insertions(+)
>   create mode 100644 net/sched/cls_openflow.c
>
> diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
> index 25731df..d4cef16 100644
> --- a/include/uapi/linux/pkt_cls.h
> +++ b/include/uapi/linux/pkt_cls.h
> @@ -402,6 +402,39 @@ enum {
>
>   #define TCA_BPF_MAX (__TCA_BPF_MAX - 1)
>
> +/* OpenFlow classifier */
> +
> +enum {
> +	TCA_OF_UNSPEC,
> +	TCA_OF_CLASSID,
> +	TCA_OF_POLICE,
> +	TCA_OF_INDEV,

I think POLICE is an old way of doing policing and INDEV if i am not
mistaken is only legit for u32 classifier.
So i am not sure you want to keep them.

Other than that looks good - will be interested to see how perfomance 
looks on this with the list walking ;->

cheers,
jamal
