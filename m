From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] ibmtr_cs/ibmtr on 2.6.0-test9 - get working again
Date: Sat, 25 Oct 2003 15:56:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031025155649.148bad99.akpm@osdl.org>
References: <20031025221435.GA18782@siasl.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, torvalds@osdl.org, jgarzik@pobox.com,
        shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mike Phillips <phillim2@comcast.net>
In-Reply-To: <20031025221435.GA18782@siasl.dyndns.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Mike Phillips <phillim2@comcast.net> wrote:
>
> -    dev = alloc_trdev(sizeof(*info));
>  +    info = kmalloc(sizeof(*info), GFP_KERNEL); 
>  +    if (!info) return NULL;
>  +    memset(info,0,sizeof(*info));
>  +    dev = alloc_trdev(sizeof(struct tok_info));
>       if (!dev)
>   	    return NULL;

This return leaks the memory at `info'.
