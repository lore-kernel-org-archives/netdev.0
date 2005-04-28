From: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Subject: Re: [PATCH] Add more explanation to tcp_prequeue comment
Date: Thu, 28 Apr 2005 18:53:45 -0300
Message-ID: <39e6f6c70504281453a903d92@mail.gmail.com>
References: <c0a09e5c05042814145901639e@mail.gmail.com>
Reply-To: acme@ghostprotocols.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Grover <andy.grover@gmail.com>
In-Reply-To: <c0a09e5c05042814145901639e@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 4/28/05, Andrew Grover <andy.grover@gmail.com> wrote:
> Here's a patch to make that prequeue comment a little clearer. Look ok?
> 
> Signed-off-by: Andy Grover <andrew.grover@intel.com>
> 
> ===== include/net/tcp.h 1.105 vs edited =====
> --- 1.105/include/net/tcp.h     2005-02-22 10:45:31 -08:00
> +++ edited/include/net/tcp.h    2005-04-28 14:02:43 -07:00
> @@ -1560,6 +1560,13 @@
>   * idea (VJ's mail "Re: query about TCP header on tcp-ip" of 07 Sep 93)
>   * failed somewhere. Latency? Burstiness? Well, at least now we will
>   * see, why it failed. 8)8)                              --ANK
> + *
> + * Actually, even though the prequeue is not as important for fast
> + * csum anymore, it is important for scheduling, to generate ACKs
> + * when the data is received by the process, not the stack.
> + * davem says, "Without prequeue, we ACK immediately. This artificially
> + * makes the sender believe it can pump data out at that rate to the
> + * receiver."

Cool, great comment, for me the funny thing is that this is one of the
differences
of DCCP x TCP, i.e. in DCCP we must ack it _before_ it gets to sk_receive_queue,
if later on we drop the packet for any reason we send DATA_DROPPED
options to the sender.

from draft-ietf-dccp-spec-11.txt:

    1.  Packets reported as State 0 or State 1 MUST be acknowledgeable:
        their options have been processed by the receiving DCCP stack.
        Any data on the packet need not have been delivered to the
        receiving application; in fact, the data may have been dropped.

    Packets dropped in the application's receive buffer MUST be reported
    as Received or Received ECN Marked (States 0 and 1), depending on
    their ECN state; such packets' ECN Nonces MUST be included in the
    Nonce Echo.  The Data Dropped option informs the sender that some
    packets reported as received actually had their application data
    dropped.

- Arnaldo
