From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/1]  hyperv: Properly handle checksum offload
Date: Fri, 25 Apr 2014 17:43:22 -0700
Message-ID: <20140425174322.589ed9f1@samsung-9>
References: <1398451514-25593-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com,
	stable@kernel.org
To: "K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1398451514-25593-1-git-send-email-kys@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 25 Apr 2014 11:45:14 -0700
"K. Y. Srinivasan" <kys@microsoft.com> wrote:

> @@ -474,6 +477,9 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
>  	csum_info = (struct ndis_tcp_ip_checksum_info *)((void *)ppi +
>  			ppi->ppi_offset);
>  
> +	ip_hdr(skb)->check = 0;
> +	csum_info->transmit.ip_header_checksum = 1;
> +
>  	if (net_trans_info & (INFO_IPV4 << 16))
>  		csum_info->transmit.is_ipv4 = 1;
>  	else

Linux doesn't need or want IP checksum offload.
It will not have any performance gain.
