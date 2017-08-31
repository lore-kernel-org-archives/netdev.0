From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v3 net-next 1/7] bpf: Add mark and priority to sock options
 that can be set
Date: Fri, 01 Sep 2017 00:21:14 +0200
Message-ID: <59A88BDA.9070609@iogearbox.net>
References: <1504217150-16151-1-git-send-email-dsahern@gmail.com> <1504217150-16151-2-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org,
        ast@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44182 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750925AbdHaWVS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 18:21:18 -0400
In-Reply-To: <1504217150-16151-2-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2017 12:05 AM, David Ahern wrote:
> Add socket mark and priority to fields that can be set by
> ebpf program when a socket is created.
>
> Signed-off-by: David Ahern <dsahern@gmail.com>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> ---
>   include/uapi/linux/bpf.h |  2 ++
>   net/core/filter.c        | 26 ++++++++++++++++++++++++++
>   2 files changed, 28 insertions(+)
>
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index d46cf326b95f..e9c89e20adff 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -758,6 +758,8 @@ struct bpf_sock {
>   	__u32 family;
>   	__u32 type;
>   	__u32 protocol;
> +	__u32 mark;
> +	__u32 priority;
>   };
>
>   #define XDP_PACKET_HEADROOM 256
> diff --git a/net/core/filter.c b/net/core/filter.c
> index c6a37fe0285b..f51b9690adf3 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -3455,6 +3455,10 @@ static bool sock_filter_is_valid_access(int off, int size,
>   		switch (off) {
>   		case offsetof(struct bpf_sock, bound_dev_if):
>   			break;
> +		case offsetof(struct bpf_sock, mark):
> +			break;
> +		case offsetof(struct bpf_sock, priority):
> +			break;

Can also be follow-up, but please do keep this consistent
to all the other *_is_valid_access() helpers, meaning:

	switch (off) {
	case offsetof(struct bpf_sock, bound_dev_if):
	case offsetof(struct bpf_sock, mark):
	case offsetof(struct bpf_sock, priority):
		break;
	default:
		return false;
	}

Rest:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
