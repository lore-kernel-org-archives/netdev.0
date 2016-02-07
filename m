From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net v3 2/4] net: add rx_nohandler stat counter
Date: Sun, 7 Feb 2016 11:37:32 -0800
Message-ID: <20160207113732.25a88cc4@xeon-e3>
References: <1453996188-29965-1-git-send-email-jarod@redhat.com>
	<1454370667-2328-1-git-send-email-jarod@redhat.com>
	<1454370667-2328-3-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tom Herbert <tom@herbertland.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454370667-2328-3-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon,  1 Feb 2016 18:51:05 -0500
Jarod Wilson <jarod@redhat.com> wrote:

> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -35,6 +35,8 @@ struct rtnl_link_stats {
>  	/* for cslip etc */
>  	__u32	rx_compressed;
>  	__u32	tx_compressed;
> +
> +	__u32	rx_nohandler;		/* dropped, no handler found	*/
>  };
>  
>  /* The main device statistics structure */
> @@ -68,6 +70,8 @@ struct rtnl_link_stats64 {
>  	/* for cslip etc */
>  	__u64	rx_compressed;
>  	__u64	tx_compressed;
> +
> +	__u64	rx_nohandler;		/* dropped, no handler found	*/
>  };

Why was this userspace ABI change allowed?
The stats structure is exposed to user space via netlink
and changing the size of responses will break iproute2 commands.

The code will be expecting one size and the response will vary and
break existing code.  Yes, the code should check the size
of the response, but it doesn't and I am sure iproute2 is not
the only code that does this.
