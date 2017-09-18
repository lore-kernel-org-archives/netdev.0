From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC V1 net-next 1/6] net: Add a new socket option for a
 future transmit time.
Date: Mon, 18 Sep 2017 08:18:54 -0700
Message-ID: <1505747934.29839.21.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1505719061.git.rcochran@linutronix.de>
         <ad6e265b97b66bcdb19b815e6d9092ffbcb461ba.1505719061.git.rcochran@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org,
        Andre Guedes <andre.guedes@intel.com>,
        Anna-Maria Gleixner <anna-maria@linutronix.de>,
        David Miller <davem@davemloft.net>,
        Henrik Austad <henrik@austad.us>,
        Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>,
        John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Vinicius Costa Gomes <vinicius.gomes@intel.com>
To: Richard Cochran <rcochran@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ad6e265b97b66bcdb19b815e6d9092ffbcb461ba.1505719061.git.rcochran@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-09-18 at 09:41 +0200, Richard Cochran wrote:

> +	case SO_TXTIME:
> +		if (!sock_flag(sk, SOCK_TXTIME))
> +			return -EINVAL;
> +		sockc->transmit_time = *(u64 *)CMSG_DATA(cmsg);

1) No guarantee the CMSG is properly aligned on arches that might trap
on unaligned access.

2) No guarantee user provided 8 bytes here.

Also, what would be the time base here ?

> +		break;
>  	/* SCM_RIGHTS and SCM_CREDENTIALS are semantically in SOL_UNIX. */
>  	case SCM_RIGHTS:
>  	case SCM_CREDENTIALS:
