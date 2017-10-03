From: Marcelo Ricardo Leitner <marcelo.leitner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V2] Fix a sleep-in-atomic bug in shash_setkey_unaligned
Date: Tue, 3 Oct 2017 19:46:32 -0300
Message-ID: <20171003224632.GF19750@localhost.localdomain>
References: <1506997522-26684-1-git-send-email-baijiaju1990@163.com>
 <20171003223308.GD19750@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org,
        nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, vyasevich-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20171003223308.GD19750-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 03, 2017 at 07:33:08PM -0300, Marcelo Ricardo Leitner wrote:
> On Tue, Oct 03, 2017 at 10:25:22AM +0800, Jia-Ju Bai wrote:
> > The SCTP program may sleep under a spinlock, and the function call path is:
> > sctp_generate_t3_rtx_event (acquire the spinlock)
> >   sctp_do_sm
> >     sctp_side_effects
> >       sctp_cmd_interpreter
> >         sctp_make_init_ack
> >           sctp_pack_cookie
> >             crypto_shash_setkey
> >               shash_setkey_unaligned
> >                 kmalloc(GFP_KERNEL)
> 
> Are you sure this can happen?
> The host is not supposed to store any information when replying to an
> INIT packet (which generated the INIT_ACK listed above). That said,
> it's weird to see the timer function triggering so.
> 
> Checking now, that code is dead actually:
> $ git grep -A 2 SCTP_CMD_GEN_INIT_ACK
> sm_sideeffect.c:                case SCTP_CMD_GEN_INIT_ACK:
> sm_sideeffect.c-                        /* Generate an INIT ACK chunk.
> */
> sm_sideeffect.c-                        new_obj =
> sctp_make_init_ack(asoc, chunk, GFP_ATOMIC,
> 
> Nobody is triggering a call to sctp_cmd_interpreter with
> SCTP_CMD_GEN_INIT_ACK command, which would generate the callstack
> above.

Nevertheless, the issue is real through other call paths.

Thanks,
Marcelo
