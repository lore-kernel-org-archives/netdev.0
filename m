From: "Johan Lundgren" <johan.lundgren@airliners.net>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Thu, 30 Mar 2006 11:49:35 +0200
Message-ID: <2399bdcc0603300149k18983d06xead26286b69b8fdd@mail.gmail.com>
References: <C925F8B43D79CC49ACD0601FB68FF50C07461F59@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: nipsy@bitgnome.net, cat@zip.com.au, djani22@dynamicweb.hu,
	yoseph.basri@gmail.com, bb@kernelpanic.ru, mykleb@no.ibm.com,
	olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org,
	"Jesse Brandeburg" <jesse.brandeburg@gmail.com>, davem@davemloft.net,
	E1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
In-Reply-To: <C925F8B43D79CC49ACD0601FB68FF50C07461F59@orsmsx408>
Content-Disposition: inline
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

Hi,

>What seems to cause this problem?

That I cannot say but the problem was fixed by removing one e1000 card
from the server (I initially had two e1000 cards installed in addition
to the two tg3 cards on the board).

Another fix was to disable TSO with ethtool.

>What motherboards are you using?

Supermicro H8DAE (dual Opteron)

>Are you all using iptables?  Are you all routing?

Iptables yes, routing no.

>none of you are using an 82571/2/3 (pci express)

Correct.

Regards,
Johan


On 3/30/06, Brandeburg, Jesse <jesse.brandeburg@intel.com> wrote:
> Hi all, I've identified you as people who have at some point in the past
> emailed one of the Linux lists with problems with e1000 and
> sk_forward_alloc.  It seems to be fairly widespread, but only seems to
> have appeared with recent kernel changes (after 2.6.12...)
>
> What I need from you is a reproducible test, and some information.  I
> have never been able to reproduce this, and I'm trying to isolate the
> problem a bit.  What motherboards are you using?  What seems to cause
> this problem?  Are you all using iptables?  Are you all routing? From
> the reports I assume none of you are using an 82571/2/3 (pci express)
>
> As far as I know e1000 has the same requirement as tg3 and some others
> where we have to modify the header of the skb in the case of transmits
> using TSO.  I don't see anywhere else that the driver modifies the skb.
> Tomorrow I'll generate a patch to try a more paranoid copying of the
> skb, I hope some of you can test.
>
> To do this we have code like so in e1000_tso:
> 2529         if (skb_shinfo(skb)->tso_size) {
> 2530                 if (skb_header_cloned(skb)) {
> 2531                         err =3D pskb_expand_head(skb, 0, 0,
> GFP_ATOMIC);
> 2532                         if (err)
> 2533                                 return err;
> 2534                 }
> 2535
> 2536                 hdr_len =3D ((skb->h.raw - skb->data) +
> (skb->h.th->doff << 2));
> 2537                 mss =3D skb_shinfo(skb)->tso_size;
> 2538                 if (skb->protocol =3D=3D ntohs(ETH_P_IP)) {
> 2539                         skb->nh.iph->tot_len =3D 0;
> 2540                         skb->nh.iph->check =3D 0;
>
> Thanks for your assistance
>
> Jesse
>


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
