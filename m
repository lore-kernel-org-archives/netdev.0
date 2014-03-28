From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] openvswitch: supply a dummy err_handler of
 gre_cisco_protocol to prevent kernel crash
Date: Fri, 28 Mar 2014 15:02:25 -0700
Message-ID: <CAEP_g=_qJ1uHKZmZdkUrT+NUkzbRgaHfShZoMbnnCb+LwjOneQ@mail.gmail.com>
References: <1395957398-24546-1-git-send-email-asuka.com@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Wei Zhang <asuka.com-9Onoh4P/yGk@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1395957398-24546-1-git-send-email-asuka.com-9Onoh4P/yGk@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Thu, Mar 27, 2014 at 2:56 PM, Wei Zhang <asuka.com-9Onoh4P/yGk@public.gmane.org> wrote:
> diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
> index a3d6951..d64c639 100644
> --- a/net/openvswitch/vport-gre.c
> +++ b/net/openvswitch/vport-gre.c
> @@ -110,6 +110,12 @@ static int gre_rcv(struct sk_buff *skb,
>         return PACKET_RCVD;
>  }
>
> +static int gre_dummy_err(struct sk_buff *skb, u32 info,
> +                        const struct tnl_ptk_info *tpi)
> +{
> +       return PACKET_REJECT;
> +}

I'm not sure that rejecting all ICMP packets is the correct thing do
here since it means that we could pass them onto a later caller even
though they are intended for us. We should probably use the same logic
as for receiving packets and just discard them here.
