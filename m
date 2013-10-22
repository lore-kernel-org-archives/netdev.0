From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] fq_codel: keep dropped statistic around
Date: Mon, 21 Oct 2013 18:27:11 -0700
Message-ID: <CAL4Wiio0YThCbT8j92HVn1CmmdvKD=GT30ZtMf=ZvmAj+ZM7Yg@mail.gmail.com>
References: <1382404797-17239-1-git-send-email-dave.taht@bufferbloat.net>
	<1382404797-17239-2-git-send-email-dave.taht@bufferbloat.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2044618405739436794=="
Cc: netdev <netdev@vger.kernel.org>, codel@lists.bufferbloat.net
To: Dave Taht <dave.taht@bufferbloat.net>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <1382404797-17239-2-git-send-email-dave.taht@bufferbloat.net>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Sender: codel-bounces@lists.bufferbloat.net
Errors-To: codel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

--===============2044618405739436794==
Content-Type: multipart/alternative; boundary=047d7b86e864beec0f04e94a4c04

--047d7b86e864beec0f04e94a4c04
Content-Type: text/plain; charset=ISO-8859-1

On Oct 21, 2013 6:20 PM, "Dave Taht" <dave.taht@bufferbloat.net> wrote:
>
> Having more accurate dropped information in this qdisc is useful.
>
> Signed-off-by: Dave Taht <dave.taht@bufferbloat.net>
> ---
>  net/sched/sch_fq_codel.c |    1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
> index 5578628..437bc95 100644
> --- a/net/sched/sch_fq_codel.c
> +++ b/net/sched/sch_fq_codel.c
> @@ -193,7 +193,6 @@ static int fq_codel_enqueue(struct sk_buff *skb,
struct Qdisc *sch)
>                 list_add_tail(&flow->flowchain, &q->new_flows);
>                 q->new_flow_count++;
>                 flow->deficit = q->quantum;
> -               flow->dropped = 0;
>         }
>         if (++sch->q.qlen <= sch->limit)
>                 return NET_XMIT_SUCCESS;
> --
> 1.7.9.5
I am travelling to Edinburgh, so will be short.

Since fqcodel recycles a slot, we need to clear this counter. We do no know
if slot is reused by previous flow or a new flow hashing to same bucket.

--047d7b86e864beec0f04e94a4c04
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr"><br>
On Oct 21, 2013 6:20 PM, &quot;Dave Taht&quot; &lt;<a href=3D"mailto:dave.t=
aht@bufferbloat.net">dave.taht@bufferbloat.net</a>&gt; wrote:<br>
&gt;<br>
&gt; Having more accurate dropped information in this qdisc is useful.<br>
&gt;<br>
&gt; Signed-off-by: Dave Taht &lt;<a href=3D"mailto:dave.taht@bufferbloat.n=
et">dave.taht@bufferbloat.net</a>&gt;<br>
&gt; ---<br>
&gt; =A0net/sched/sch_fq_codel.c | =A0 =A01 -<br>
&gt; =A01 file changed, 1 deletion(-)<br>
&gt;<br>
&gt; diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c<br>
&gt; index 5578628..437bc95 100644<br>
&gt; --- a/net/sched/sch_fq_codel.c<br>
&gt; +++ b/net/sched/sch_fq_codel.c<br>
&gt; @@ -193,7 +193,6 @@ static int fq_codel_enqueue(struct sk_buff *skb, s=
truct Qdisc *sch)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_add_tail(&amp;flow-&gt;flowchain,=
 &amp;q-&gt;new_flows);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 q-&gt;new_flow_count++;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 flow-&gt;deficit =3D q-&gt;quantum;<br=
>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 flow-&gt;dropped =3D 0;<br>
&gt; =A0 =A0 =A0 =A0 }<br>
&gt; =A0 =A0 =A0 =A0 if (++sch-&gt;q.qlen &lt;=3D sch-&gt;limit)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NET_XMIT_SUCCESS;<br>
&gt; --<br>
&gt; 1.7.9.5<br>
 I am travelling to Edinburgh, so will be short.</p>
<p dir=3D"ltr">Since fqcodel recycles a slot, we need to clear this counter=
. We do no know if slot is reused by previous flow or a new flow hashing to=
 same bucket.<br>
</p>

--047d7b86e864beec0f04e94a4c04--

--===============2044618405739436794==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Codel mailing list
Codel@lists.bufferbloat.net
https://lists.bufferbloat.net/listinfo/codel

--===============2044618405739436794==--
