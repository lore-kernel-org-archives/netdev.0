From: Jonathan Brassow <jbrassow@redhat.com>
Subject: Re: [PATCH 5/8] dm/connector: Only process connector
	packages from privileged processes
Date: Fri, 2 Oct 2009 11:40:10 -0500
Message-ID: <8D9D8D38-82E2-41A9-96A1-EF026B7ADE49@redhat.com>
References: <1254487211-11810-1-git-send-email-philipp.reisner@linbit.com>
	<1254487211-11810-2-git-send-email-philipp.reisner@linbit.com>
	<1254487211-11810-3-git-send-email-philipp.reisner@linbit.com>
	<1254487211-11810-4-git-send-email-philipp.reisner@linbit.com>
	<1254487211-11810-5-git-send-email-philipp.reisner@linbit.com>
	<1254487211-11810-6-git-send-email-philipp.reisner@linbit.com>
Reply-To: device-mapper development <dm-devel@redhat.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: multipart/mixed; boundary="===============1303743914=="
Cc: linux-fbdev-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Philipp Reisner <philipp.reisner@linbit.com>,
	Greg KH <greg@kroah.com>, Evgeniy Polyakov <zbr@ioremap.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, Alasdair Kergon <agk@redhat.com>
To: device-mapper development <dm-devel@redhat.com>
Return-path: <dm-devel-bounces@redhat.com>
In-Reply-To: <1254487211-11810-6-git-send-email-philipp.reisner@linbit.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/dm-devel>
List-Post: <mailto:dm-devel@redhat.com>
List-Help: <mailto:dm-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=subscribe>
Sender: dm-devel-bounces@redhat.com
Errors-To: dm-devel-bounces@redhat.com
List-Id: netdev.vger.kernel.org


--===============1303743914==
Content-Type: multipart/alternative; boundary=Apple-Mail-1--830980382


--Apple-Mail-1--830980382
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed;
	delsp=yes
Content-Transfer-Encoding: 7bit

This patch (and "[dm-devel] [PATCH 3/8] connector/dm: Fixed a  
compilation warning") will likely collide with an earlier patch (which  
agk is pushing) to fix the compilation warning (https://www.redhat.com/archives/dm-devel/2009-September/msg00218.html 
), but the fix-up will be trivial.

The dm-log-userspace code checks that incoming messages correspond to  
requests that were sent to userspace by way of a sequence number.  If  
they don't correspond, they are dropped.  So, you must be able to  
receive the messages from this kernel module (be root) in order to be  
able respond with a message that will be accepted.  I can't completely  
rule out the ability to guess a sequence number, and be able to beat  
the log daemon in responding while the window of that sequence  
number's validity is open though...  If someone could manage to pull  
this off with accuracy, they could disrupt the creation of a device,  
mimic a log device failure, or cause mirror resynchronization to occur  
to a different area that may simultaneously be performing a write  
(potential data corruption of a mirror).  It would be an impressive  
feat to accomplish this, but I very much welcome the patch rather than  
test fate.

Reviewed-by: Jonathan Brassow <jbrassow@redhat.com>

  brassow

On Oct 2, 2009, at 7:40 AM, Philipp Reisner wrote:

> Signed-off-by: Philipp Reisner <philipp.reisner@linbit.com>
> ---
> drivers/md/dm-log-userspace-transfer.c |    3 +++
> 1 files changed, 3 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/md/dm-log-userspace-transfer.c b/drivers/md/dm- 
> log-userspace-transfer.c
> index 1327e1a..54abf9e 100644
> --- a/drivers/md/dm-log-userspace-transfer.c
> +++ b/drivers/md/dm-log-userspace-transfer.c
> @@ -133,6 +133,9 @@ static void cn_ulog_callback(struct cn_msg *msg,  
> struct netlink_skb_parms *nsp)
> {
> 	struct dm_ulog_request *tfr = (struct dm_ulog_request *)(msg + 1);
>
> +	if (!cap_raised(nsp->eff_cap, CAP_SYS_ADMIN))
> +		return;
> +
> 	spin_lock(&receiving_list_lock);
> 	if (msg->len == 0)
> 		fill_pkg(msg, NULL);
> -- 
> 1.6.0.4
>
> --
> dm-devel mailing list
> dm-devel@redhat.com
> https://www.redhat.com/mailman/listinfo/dm-devel


--Apple-Mail-1--830980382
Content-Type: text/html;
	charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

<html><body style=3D"word-wrap: break-word; -webkit-nbsp-mode: space; =
-webkit-line-break: after-white-space; "><div>This patch (and "<span =
class=3D"Apple-style-span" style=3D"font-size: 12px; font-weight: bold; =
">[dm-devel] [PATCH 3/8] connector/dm: Fixed a compilation warning<span =
class=3D"Apple-style-span" style=3D"font-size: medium; font-weight: =
normal; ">") will likely collide with an earlier patch (which agk is =
pushing) to fix the compilation warning (<a =
href=3D"https://www.redhat.com/archives/dm-devel/2009-September/msg00218.h=
tml)">https://www.redhat.com/archives/dm-devel/2009-September/msg00218.htm=
l)</a>, but the fix-up will be =
trivial.</span></span></div><div><br></div><div>The dm-log-userspace =
code checks that incoming messages correspond to requests that were sent =
to userspace by way of a sequence number. &nbsp;If they don't =
correspond, they are dropped. &nbsp;So, you must be able to receive the =
messages from this kernel module (be root) in order to be able respond =
with a message that will be accepted. &nbsp;I can't completely rule out =
the ability to guess a sequence number, and be able to beat the log =
daemon in responding while the window of that sequence number's validity =
is open though... &nbsp;If someone could manage to pull this off with =
accuracy, they could disrupt the creation of a device, mimic a log =
device failure, or cause mirror resynchronization to occur to a =
different area that may simultaneously be performing a write (potential =
data corruption of a mirror). &nbsp;It would be an impressive feat to =
accomplish this, but I very much welcome the patch rather than test =
fate.</div><div><br></div>Reviewed-by: Jonathan Brassow &lt;<a =
href=3D"mailto:jbrassow@redhat.com">jbrassow@redhat.com</a>&gt;<br><div><d=
iv><br></div><div>&nbsp;brassow</div><div><br></div><div>On Oct 2, 2009, =
at 7:40 AM, Philipp Reisner wrote:</div><br =
class=3D"Apple-interchange-newline"><blockquote =
type=3D"cite"><div>Signed-off-by: Philipp Reisner &lt;<a =
href=3D"mailto:philipp.reisner@linbit.com">philipp.reisner@linbit.com</a>&=
gt;<br>---<br> drivers/md/dm-log-userspace-transfer.c | =
&nbsp;&nbsp;&nbsp;3 +++<br> 1 files changed, 3 insertions(+), 0 =
deletions(-)<br><br>diff --git a/drivers/md/dm-log-userspace-transfer.c =
b/drivers/md/dm-log-userspace-transfer.c<br>index 1327e1a..54abf9e =
100644<br>--- a/drivers/md/dm-log-userspace-transfer.c<br>+++ =
b/drivers/md/dm-log-userspace-transfer.c<br>@@ -133,6 +133,9 @@ static =
void cn_ulog_callback(struct cn_msg *msg, struct netlink_skb_parms =
*nsp)<br> {<br> <span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>struct dm_ulog_request *tfr =3D (struct dm_ulog_request *)(msg + =
1);<br><br>+<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>if (!cap_raised(nsp-&gt;eff_cap, CAP_SYS_ADMIN))<br>+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>return;<br>+<br> <span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	=
</span>spin_lock(&amp;receiving_list_lock);<br> <span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>if =
(msg-&gt;len =3D=3D 0)<br> <span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>fill_pkg(msg, NULL);<br>-- =
<br>1.6.0.4<br><br>--<br>dm-devel mailing list<br><a =
href=3D"mailto:dm-devel@redhat.com">dm-devel@redhat.com</a><br>https://www=
.redhat.com/mailman/listinfo/dm-devel<br></div></blockquote></div><br></bo=
dy></html>=

--Apple-Mail-1--830980382--


--===============1303743914==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============1303743914==--
