From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH]  802.1Q VLAN
Date: Sat, 23 Oct 2004 02:24:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041023002425.GB4948@electric-eye.fr.zoreil.com>
References: <41797696.9070905@candelatech.com> <20041022214611.GA4948@electric-eye.fr.zoreil.com> <41798506.1030909@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <41798506.1030909@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

(vlan cc: bounces)

Ben Greear <greearb@candelatech.com> :
[...]
> @@ -1253,6 +1272,17 @@
>   *	A negative errno code is returned on a failure. A success does not
>   *	guarantee the frame will be transmitted as it may be dropped due
>   *	to congestion or traffic shaping.
> + *
> + * 
> -----------------------------------------------------------------------------------
> + *      I notice this method can also return errors from the queue disciplines,
> + *      including NET_XMIT_DROP, which is a positive value.  So, errors can also
> + *      be positive.
> + *
> + *      Regardless of the return value, the skb is consumed, so it is currently
> + *      impossible to retry a send to this method.  This implies that virtual devices,
> + *      such as VLANs, can ONLY return 0 from their hard_start_xmit method, making
> + *      it difficult to apply pressure back up the stack.
> + *          --Ben
>   */

Afaikr it is not true anymore with the previous code as the congestion/error
status is propagated and the extra skb_get() balances the kfree_skb() on error
in dev_queue_xmit. So I'd say that vlan_dev_hard_start_xmit() seems to behave
like a normal start_xmit() instead.

--
Ueimor
