From: Mike_Phillips@URSCorp.com
Subject: Re: [PATCH] (5/6) ibmtr -- probe2
Date: Mon, 20 Oct 2003 07:07:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF2F733E52.5ED0F881-ON88256DC5.004D42A4-88256DC5.004D8F9D@urscorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


>The problem with the structures was a BUG in the existing code!
>The PCMCIA code was setting dev->priv to a structure:

>struct ibmtr_dev_t {
>    dev_link_t                      link;
>    struct net_device         *dev;
>    dev_node_t          node;
>    window_handle_t     sram_win_handle;
>    struct tok_info           ti;
>}

>and then later when registered, the dev->init callback goes to ibmtr_probe
and
>then ibmtr_probe1 which expects dev->priv to point to 'struct tok_info'

>The code is broken in 2.6.0-test7.

Interesting that it's worked for 4 yrs then really ;) The fix is wrong too
then, if the code is really set the pointer to the wrong location, then
just moving the tok_info to the beginning of the struct is an ugly kludge.
It should be fixed the right way.

No worries, let me take a look at it all and remember exactly why it was
written this way and test with hardware.

Mike
