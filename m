From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] bridge: fix hello and hold timers
	starting/stopping
Date: Sat, 20 May 2017 01:26:35 +0800
Message-ID: <CADvbK_f5BHSep078a8cTNfYcnZmATnsX9nJDfb2ZTikcVnPZmA@mail.gmail.com>
References: <20170519162543.31670-1-cera@cera.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	network dev <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org, davem <davem@davemloft.net>
To: Ivan Vecera <cera@cera.cz>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170519162543.31670-1-cera@cera.cz>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Sat, May 20, 2017 at 12:25 AM, Ivan Vecera <cera@cera.cz> wrote:
[...]
> @@ -197,13 +191,14 @@ static void br_stp_stop(struct net_bridge *br)
>                         br_err(br, "failed to stop userspace STP (%d)\n", err);
>
>                 /* To start timers on any ports left in blocking */
> -               mod_timer(&br->hello_timer, jiffies + br->hello_time);
> -               list_for_each_entry(p, &br->port_list, list)
> -                       mod_timer(&p->hold_timer,
> -                                 round_jiffies(jiffies + BR_HOLD_TIME));
>                 spin_lock_bh(&br->lock);
>                 br_port_state_selection(br);
>                 spin_unlock_bh(&br->lock);
> +       } else {
> +               /* BR_KERNEL_STP - stop hello and hold timers */
> +               del_timer(&br->hello_timer);
> +               list_for_each_entry(p, &br->port_list, list)
> +                       del_timer(&p->hold_timer);
>         }
>
>         br->stp_enabled = BR_NO_STP;
I have a question here, br->stp_enabled is not atomic, and it is being
changed without holding br->lock here, while it may be checked in
br_hello_timer_expired, is it safe ?

(sorry if I misunderstood or overthought about it)

> --
> 2.13.0
>
