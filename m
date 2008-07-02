From: SathyaNarayanan <sathyan@teamf1.com>
Subject: Re: [PATCH] ibm_newemac: Fixes memory leak in ibm_newemac ethernet
	driver
Date: Wed, 2 Jul 2008 11:41:41 +0530
Message-ID: <1946a170807012311o1595d9d1r477fabc8f4504f7d@mail.gmail.com>
References: <1214225712-25882-1-git-send-email-sr@denx.de>
	<1214263310.8011.280.camel@pasglop>
	<1946a170807012145v6e6d629cvea443f2b8462d708@mail.gmail.com>
	<1214977560.21182.35.camel@pasglop>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1324172280=="
Cc: linuxppc-dev@ozlabs.org, Stefan Roese <sr@denx.de>, netdev@vger.kernel.org
To: benh@kernel.crashing.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <1214977560.21182.35.camel@pasglop>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Mime-version: 1.0
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

--===============1324172280==
Content-Type: multipart/alternative;
	boundary="----=_Part_3515_8103274.1214979101172"

------=_Part_3515_8103274.1214979101172
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Wed, Jul 2, 2008 at 11:16 AM, Benjamin Herrenschmidt <
benh@kernel.crashing.org> wrote:

>
> >
> > Actually the meachanism of stopping the queue and starting it is
> > already there.  But even then due to some sync issue between the poll
> > routine and xmit, we were resulted in using the slots of skb which was
> > not actually got freed before.
> > I agree this could a bug , Since its not is not clear why buffers are
> > not getting transferred timely?. But to handle this we should have a
> > work around otherwise system may go out of memory. If we go for
> > stopping the queue in these scenario also ( Where a unfreed skbs slot
> > has been assigned  to another ), Then kernel may call tx timeout, And
> > reset the driver. In that case handelling this special case here could
> > lead us better performance as compared to stopping the queue
> > Let me know your comments.
>
> Well, if we have a bug, we need to fix it. ie, understand how it is that
> the existing mechanism to stop the queue doesn't work, and prevent xmit
> from overwriting a non-clear transmit slot (possibly displaying an error
> to help us track down the bug).
>
> I'll have to dig a bit, I'll see if I can find some time tomorrow.


The reason could be sync issue between poll and xmit. I would like to have
one clarification , Why in the present design no locks has been implemented
to protect the queue from simulatenous access ??

>
>
> Cheers,
> Ben.
>
>
>
>

------=_Part_3515_8103274.1214979101172
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

<br><br><div class="gmail_quote">On Wed, Jul 2, 2008 at 11:16 AM, Benjamin Herrenschmidt &lt;<a href="mailto:benh@kernel.crashing.org">benh@kernel.crashing.org</a>&gt; wrote:<br><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
<div class="Ih2E3d"><br>
&gt;<br>
&gt; Actually the meachanism of stopping the queue and starting it is<br>
&gt; already there. &nbsp;But even then due to some sync issue between the poll<br>
&gt; routine and xmit, we were resulted in using the slots of skb which was<br>
&gt; not actually got freed before.<br>
&gt; I agree this could a bug , Since its not is not clear why buffers are<br>
&gt; not getting transferred timely?. But to handle this we should have a<br>
&gt; work around otherwise system may go out of memory. If we go for<br>
&gt; stopping the queue in these scenario also ( Where a unfreed skbs slot<br>
&gt; has been assigned &nbsp;to another ), Then kernel may call tx timeout, And<br>
&gt; reset the driver. In that case handelling this special case here could<br>
&gt; lead us better performance as compared to stopping the queue<br>
&gt; Let me know your comments.<br>
<br>
</div>Well, if we have a bug, we need to fix it. ie, understand how it is that<br>
the existing mechanism to stop the queue doesn&#39;t work, and prevent xmit<br>
from overwriting a non-clear transmit slot (possibly displaying an error<br>
to help us track down the bug).<br>
<br>
I&#39;ll have to dig a bit, I&#39;ll see if I can find some time tomorrow.</blockquote><div><br>The reason could be sync issue between poll and xmit. I would like to have one clarification , Why in the present design no locks has been implemented to protect the queue from simulatenous access ??<br>
</div><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;"><br>
<br>
Cheers,<br>
Ben.<br>
<br>
<br>
<br>
</blockquote></div><br>

------=_Part_3515_8103274.1214979101172--

--===============1324172280==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc-dev
--===============1324172280==--
