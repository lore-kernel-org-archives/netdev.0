From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH V5] netfilter: h323: avoid potential attack
Date: Tue, 2 Feb 2016 13:55:27 +0300
Message-ID: <56B08B1F.9050406@cogentembedded.com>
References: <1454391454-22359-1-git-send-email-zhouzhouyi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Zhouyi Zhou <yizhouzhou@ict.ac.cn>
To: Zhouyi Zhou <zhouzhouyi@gmail.com>, eric.dumazet@gmail.com,
	pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fw@strlen.de,
	gnomes@lxorguk.ukuu.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454391454-22359-1-git-send-email-zhouzhouyi@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 2/2/2016 8:37 AM, Zhouyi Zhou wrote:

> I think hackers chould build a malicious h323 packet to overflow
> the pointer p which will panic during the memcpy(addr, p, len)
> For example, he may fabricate a very large taddr->ipAddress.ip.
>
> In order to avoid this, I add a valid memory reference check in
>   get_h2x5_addr functions.
>
> As suggested by Eric, this module is protected by a lock (nf_h323_lock)
> so adding a variable h323_buffer_valid_bytes that would contain
> the number of valid bytes would not require to change prototypes of
> get_h2x5_addr.
>
> Signed-off-by: Zhouyi Zhou <yizhouzhou@ict.ac.cn>
>
> ---
>   net/netfilter/nf_conntrack_h323_main.c | 27 +++++++++++++++++++++++++++
>   1 file changed, 27 insertions(+)
>
> diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
> index 9511af0..21665ec 100644
> --- a/net/netfilter/nf_conntrack_h323_main.c
> +++ b/net/netfilter/nf_conntrack_h323_main.c
> @@ -110,6 +110,25 @@ int (*nat_q931_hook) (struct sk_buff *skb,
>
>   static DEFINE_SPINLOCK(nf_h323_lock);
>   static char *h323_buffer;
> +static int h323_buffer_valid_bytes;
> +
> +static bool h323_buffer_ref_valid(void *p, int len)
> +{
> +
> +	if ((unsigned long)len > h323_buffer_valid_bytes) {
> +		return false;
> +	}

    {} not needed.

> +
> +	if (p + len > (void *)h323_buffer + h323_buffer_valid_bytes) {
> +		return false;
> +	}

    Likewise.

> +
> +	if (p < (void *)h323_buffer) {
> +		return false;
> +	}

    Likewise.

[...]

MBR, Sergei
