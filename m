From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH] net: xilinx_emaclite: Fix problem with first incoming
	packet
Date: Tue, 22 Sep 2009 09:53:43 -0700
Message-ID: <fa686aa40909220953g708445d9s9c25bd839cc2dd2e@mail.gmail.com>
References: <fac40d47-5b19-4225-9fee-f7a058851fc0@SG2EHSMHS017.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Michal Simek <monstr@monstr.eu>, sadanand.mutyala@xilinx.com,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, davem@davemloft.net
To: John Linn <john.linn@xilinx.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <fac40d47-5b19-4225-9fee-f7a058851fc0@SG2EHSMHS017.ehs.local>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 22, 2009 at 8:24 AM, John Linn <john.linn@xilinx.com> wrote:
> From: Michal Simek <monstr@monstr.eu>
>
> You can't ping the board or connect to it unless you send
> any packet out from board.
>
> Tested-by: John Williams <john.williams@petalogix.com>
> Signed-off-by: Michal Simek <monstr@monstr.eu>
> Acked-by: John Linn <john.linn@xilinx.com>

John, Since this patch is being *sent* by you, then you should use a
"signed-off-by" tag instead because it actually passed through your
hands.

Oh, and:
Acked-by: Grant Likely <grant.likely@secretlab.ca>

> ---
> =A0drivers/net/xilinx_emaclite.c | =A0 =A07 ++-----
> =A01 files changed, 2 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/xilinx_emaclite.c b/drivers/net/xilinx_emaclite.c
> index dc22782..83a044d 100644
> --- a/drivers/net/xilinx_emaclite.c
> +++ b/drivers/net/xilinx_emaclite.c
> @@ -134,18 +134,15 @@ static void xemaclite_enable_interrupts(struct net_=
local *drvdata)
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0/* Enable the Rx interrupts for the first buffer */
> - =A0 =A0 =A0 reg_data =3D in_be32(drvdata->base_addr + XEL_RSR_OFFSET);
> =A0 =A0 =A0 =A0out_be32(drvdata->base_addr + XEL_RSR_OFFSET,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reg_data | XEL_RSR_RECV_IE_MASK);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0XEL_RSR_RECV_IE_MASK);
>
> =A0 =A0 =A0 =A0/* Enable the Rx interrupts for the second Buffer if
> =A0 =A0 =A0 =A0 * configured in HW */
> =A0 =A0 =A0 =A0if (drvdata->rx_ping_pong !=3D 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 reg_data =3D in_be32(drvdata->base_addr + X=
EL_BUFFER_OFFSET +
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0XEL_=
RSR_OFFSET);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0out_be32(drvdata->base_addr + XEL_BUFFER_O=
FFSET +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 XEL_RSR_OFFSET,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reg_data | XEL_RSR_RECV_=
IE_MASK);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0XEL_RSR_RECV_IE_MASK);
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0/* Enable the Global Interrupt Enable */
> --
> 1.6.2.1
>
>
>
> This email and any attachments are intended for the sole use of the named=
 recipient(s) and contain(s) confidential information that may be proprieta=
ry, privileged or copyrighted under applicable law. If you are not the inte=
nded recipient, do not read, copy, or forward this email message or any att=
achments. Delete this email message and any attachments immediately.
>
>
>



-- =

Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
